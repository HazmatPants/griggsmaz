extends StaticBody3D

@onready var viewportContainer := $SubViewportContainer
@onready var terminalInput := $SubViewportContainer/Viewport/Control/VBoxContainer/LineEdit
@onready var terminalOutput :=$SubViewportContainer/Viewport/Control/VBoxContainer/CodeEdit
@onready var currentPathLabel := $SubViewportContainer/Viewport/Control/VBoxContainer/CWD
@onready var floppyDrive := $"../FloppyDiskDrive"

@onready var player = get_tree().get_root().get_node("base/Player")
@onready var playerGUI = get_tree().get_root().get_node("base/PlayerGUI/Control")

var terminal_focus := false

var fs = {
	"/": {
		"home": {
			"notes.txt": "Don't forget to fuel the nuclear reactor.",
			"radioman.wav": preload("res://assets/sound/music/radioman.wav")
		},
		"dev": {
			"sda": generate_random_bytes(1024)
		},
		"etc": {
			"mtab": {}
		},
		"mnt": {
			
		}
	}
}

var mtab := {}

var current_path = ["/", "home"]

@onready var audio_player := $SFXPlayer

var key_sounds := GLOBAL.load_sounds_from_dir("res://assets/sound/sfx/ui/keypress/key")
var back_key_sounds := GLOBAL.load_sounds_from_dir("res://assets/sound/sfx/ui/keypress/back")
var enter_key_sounds := GLOBAL.load_sounds_from_dir("res://assets/sound/sfx/ui/keypress/enter")

func _ready() -> void:
	viewportContainer.visible = false
	terminalOutput.text = "Welcome to GIOS v0.1!\nType \"help\" for a list of commands"
	terminalInput.text_submitted.connect(_on_terminalInput_text_submitted)
	
	floppyDrive.DiskInserted.connect(_disk_inserted)
	floppyDrive.DiskEjected.connect(_disk_ejected)

func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		if terminal_focus:
			close_terminal()

func interact():
	if not terminal_focus:
		GLOBAL.CanPause = false
		player.input_enabled = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		terminal_focus = true
		viewportContainer.visible = true
		remove_child(viewportContainer)
		playerGUI.add_child(viewportContainer)
		
		terminalInput.grab_focus()

func close_terminal():
	GLOBAL.CanPause = true
	player.input_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	terminal_focus = false
	viewportContainer.visible = false
	playerGUI.remove_child(viewportContainer)
	add_child(viewportContainer)

func _input(event):
	if terminal_focus and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_META]:
			return
		
		match event.keycode:
			KEY_BACKSPACE:
				audio_player.play_stream(back_key_sounds[randi_range(0, back_key_sounds.size() - 1)])
			KEY_ENTER:
				audio_player.play_stream(enter_key_sounds[randi_range(0, enter_key_sounds.size() - 1)])
			_:
				audio_player.play_stream(key_sounds[randi_range(0, key_sounds.size() - 1)])

func _on_terminalInput_text_submitted(new_text: String):
	terminalInput.text = ""
	var command := new_text.strip_edges()
	parse_command(command)

func generate_random_bytes(count: int) -> PackedByteArray:
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var bytes = PackedByteArray()
	for i in count:
		var byte = rng.randi_range(0, 255)
		bytes.append(byte)
	
	return bytes

func parse_and_execute(input: String) -> void:
	var output_redirect: String = ""
	var append_mode := false

	# Check for >> first (append)
	if input.find(">>") != -1:
		var parts = input.split(">>", false, 2)
		input = parts[0].strip_edges()
		output_redirect = parts[1].strip_edges()
		append_mode = true
	# Then check for > (overwrite)
	elif input.find(">") != -1:
		var parts = input.split(">", false, 2)
		input = parts[0].strip_edges()
		output_redirect = parts[1].strip_edges()

	# Tokenize the command
	var args := input.split(" ")
	
	var command := args[0]
	args = args.slice(1)

	# Run the command and capture its output
	var result = await run_command(command, args)

	# Handle redirection
	if output_redirect != "":
		write_file(output_redirect, result, append_mode)
	else:
		if result != null:
			print_to_terminal(result)

func parse_command(cmd: String):
	terminalInput.grab_focus()
	print_to_terminal("$ " + cmd)
	
	parse_and_execute(cmd)

func run_command(command, args):
	# implemented commands
	match command:
		"help":
			return "Available commands: 
			help: shows this message
			clear: clears the terminal output
			echo: display a line of text
			floppy: commands for managing floppy disks
				mount: mount a floppy disk's filesystem
				umount: unmount a floppy disk's filesystem
			cd: change the current working directory
			ls: list directory contents
			pwd: print the current working directory
			mkdir: create directory
			cat: print on the standard output
			file: determine file type
			"
		"clear":
			terminalOutput.text = ""
		"echo":
			return cmd_echo(args)
		"floppy":
			return await cmd_floppy(args)
		"cd":
			cmd_cd(args)
		"ls":
			return cmd_ls(args)
		"pwd":
			cmd_pwd()
		"mkdir":
			cmd_mkdir(args)
		"cat":
			return cmd_cat(args)
		"file":
			return cmd_file(args)
		_:
			return "gish: command not found: " + command

func print_to_terminal(text: String):
	terminalOutput.text += "\n" + text
	terminalOutput.scroll_vertical = len(terminalOutput.text)

func get_current_dir() -> Dictionary:
	var dir = fs["/"]
	for part in current_path.slice(1):
		if part in dir:
			dir = dir[part]
		else:
			return {}
	return dir

func resolve_path(path: String) -> Variant:
	var combined_parts: Array

	if path.begins_with("/"):
		# Absolute path
		combined_parts = path.strip_edges(true, false).split("/")
	else:
		# Relative path
		combined_parts = current_path.slice(1).duplicate()  # exclude "/"
		combined_parts.append_array(path.split("/"))

	# Normalize the path (handle "." and "..")
	var clean_parts: Array = []
	for part in combined_parts:
		if part == "" or part == ".":
			continue
		elif part == "..":
			if clean_parts.size() > 0:
				clean_parts.pop_back()
		else:
			clean_parts.append(part)

	# Traverse from fs["/"]
	var dir_ref = fs["/"]
	for i in range(clean_parts.size()):
		var part = clean_parts[i]
		if part in dir_ref:
			if i == clean_parts.size() - 1:
				# Final part: return file or directory
				return dir_ref[part]
			elif typeof(dir_ref[part]) == TYPE_DICTIONARY:
				dir_ref = dir_ref[part]
			else:
				return null  # Trying to traverse into a file
		else:
			return null  # Invalid path

	return dir_ref  # for root or valid directory

func cmd_echo(args):
	var echo := " ".join(Array(args))
	return echo

func cmd_ls(args: Array) -> String:
	var target_dir: Dictionary

	if args.size() == 0:
		# No args = list current dir
		target_dir = resolve_path("/" + "/".join(current_path))
	else:
		# Resolve path (absolute or relative)
		var target: String = args[0]
		var resolved = resolve_path(target)
		if resolved == null:
			print_to_terminal("ls: cannot access '%s': No such file or directory" % target)
			return ""
		
		if typeof(resolved) != TYPE_DICTIONARY:
			print_to_terminal("ls: '%s' is not a directory" % target)
			return ""

		target_dir = resolved
	
	if target_dir.is_empty():
		return "<empty>"
	else:
		return "  ".join(target_dir.keys())

func cmd_pwd():
	print_to_terminal("/" + "/".join(current_path.slice(1)))

func cmd_cd(args: Array) -> void:
	if args.size() == 0:
		current_path = ["/", "home"]
		currentPathLabel.text = "/" + "/".join(current_path.slice(1))
		return

	var target = args[0]
	var resolved_dir = resolve_path(target)

	if resolved_dir == null:
		print_to_terminal("cd: no such file or directory: " + target)
		return

	if typeof(resolved_dir) != TYPE_DICTIONARY:
		print_to_terminal("cd: not a directory: " + target)
		return

	if target.begins_with("/"):
		# Absolute path
		current_path = ["/"]
		for part in target.split("/", false):
			if part != "":
				current_path.append(part)
		currentPathLabel.text = "/" + "/".join(current_path.slice(1))
	else:
		# Relative path
		var parts = target.split("/", false)
		for part in parts:
			if part == "..":
				if current_path.size() > 1:
					current_path.pop_back()
			elif part != "." and part != "":
				current_path.append(part)
		currentPathLabel.text = "/" + "/".join(current_path.slice(1))

func cmd_mkdir(args):
	if args.size() == 0:
		print_to_terminal("mkdir: missing operand")
		return
	
	var dir_name = args[0]
	var dir = get_current_dir()
	
	if dir_name in dir:
		print_to_terminal("mkdir: cannot create directory ‘" + dir_name + "’: File exists")
	else:
		dir[dir_name] = {}

func cmd_floppy(args) -> String:
	if args.size() < 1:
		return "floppy: missing subcommand\nsubcommands: 'eject', 'mount'"

	var subcommand = args[0]

	match subcommand:
		"eject":
			return floppy_eject()
		"mount":
			return await floppy_mount()
		"umount":
			return await floppy_umount(args)
	
	return ""

func cmd_cat(args: Array) -> String:
	if args.size() == 0:
		print_to_terminal("cat: missing file operand")
		return ""

	for path in args:
		var file = resolve_path(path)
		if file == null:
			print_to_terminal("cat: %s: No such file or directory" % path)
			continue

		if typeof(file) == TYPE_DICTIONARY:
			print_to_terminal("cat: %s: Is a directory" % path)
			continue
		
		return str(file)
	
	return ""

func floppy_eject():
	if floppyDrive.Disk == null:
		print_to_terminal("floppy: eject: cannot eject, no disk inserted")
	else:
		floppyDrive.eject_disk()

func write_file(path: String, contents: String="", append: bool=false) -> void:
	var full_path_parts := []
	var parts := path.strip_edges(true, false).split("/")

	if path.begins_with("/"):
		full_path_parts = parts
	else:
		full_path_parts = current_path.duplicate()
		full_path_parts.append_array(parts)

	if full_path_parts.size() == 0:
		print_to_terminal("write: invalid path")
		return

	var file_name: Variant = full_path_parts.pop_back()
	var dir: Variant = resolve_path("/" + "/".join(full_path_parts))

	if dir == null or typeof(dir) != TYPE_DICTIONARY:
		print_to_terminal("write: cannot write to '%s': No such directory" % path)
		return

	if not dir.has(file_name):
		dir[file_name] = ""

	if append:
		dir[file_name] += contents + "\n"
	else:
		dir[file_name] = contents + "\n"



func delete_file(path: String) -> void:
	var parts: Array = path.split("/")
	var file_name: String = parts.pop_back()
	
	var dir: Variant = resolve_path("/" + "/".join(parts))
	if dir.is_empty():
		push_error("delete_file: cannot delete '" + path + "': Invalid path")
		return
	
	if not dir.has(file_name):
		push_error("delete_file: '" + file_name + "' does not exist")
		return
	
	if typeof(dir[file_name]) == TYPE_DICTIONARY:
		push_error("delete_file: '" + file_name + "' is a directory")
		return
	
	dir.erase(file_name)
	print("Deleted '" + file_name + "'")

func cmd_file(args) -> String:
	if args.size() == 0:
		return "file: missing file operand"
	
	var filepath: String = args[0]
	var file = resolve_path(filepath)
	
	return get_file_description(file)

func get_file_description(file: Variant) -> String:
	match typeof(file):
		TYPE_STRING:
			return "UTF-8 Unicode text"
		TYPE_INT:
			return "integer data"
		TYPE_FLOAT:
			return "floating point data"
		TYPE_BOOL:
			return "boolean"
		TYPE_DICTIONARY:
			return "directory"
		TYPE_ARRAY:
			return "array data"
		TYPE_PACKED_BYTE_ARRAY:
			return "block special"
		TYPE_OBJECT:
			if file is AudioStreamWAV:
				return describe_audio_wav(file)
			elif file is AudioStreamOggVorbis:
				return "OGG Vorbis AudioStream"
			elif file is AudioStream:
				return "AudioStream"
			elif file is Texture2D:
				return "Texture2DD"
			elif file is Resource:
				return "Godot resource"
			else:
				return file.get_class()
		_:
			return "unknown data type"
	

func describe_audio_wav(stream: AudioStreamWAV) -> String:
	var stereo = "stereo" if stream.stereo else "mono"
	var format = "Microsoft PCM"
	return "RIFF (little-endian) data, WAVE audio, %s, 16 bit, %s %d Hz" % [
		format,
		stereo,
		int(stream.mix_rate)
	]

func floppy_mount() -> String:
	if floppyDrive.Disk == null:
		return "No disk inserted."
	
	floppyDrive.play_access_sound()
	
	if "/mnt/floppy0" in mtab:
		return "floppy0: device already mounted"

	for i in randi_range(3, 5):
		floppyDrive.play_access_sound()
		await get_tree().create_timer(randf_range(0.5, 1.0)).timeout
	
	floppyDrive.play_access_sound()
	if floppyDrive.DiskController.ReadOnly:
		print_to_terminal("floppy0: WARNING: Disk is read-only")
	
	# Create /mnt if missing
	var mnt: Variant = resolve_path("/mnt")
	if mnt == null:
		var root: Variant = resolve_path("/")
		root["mnt"] = {}
		mnt = root["mnt"]

	# Find next available floppy mount point: floppy0, floppy1, ...
	var i := 0
	while true:
		var mount_name := "floppy%d" % i
		if not mnt.has(mount_name):
			mnt[mount_name] = floppyDrive.DiskController.duplicate_contents(floppyDrive.DiskController.DiskContents)
			mtab["/mnt/floppy0"] = {
				"device": "floppy0",
				"readonly": floppyDrive.DiskController.ReadOnly
			}
			
			var fs_mtab = resolve_path("/etc/mtab")
			fs_mtab["/mnt/floppy0"] = mtab["/mnt/floppy0"]
			return "Disk mounted at /mnt/%s" % mount_name
		i += 1
	return ""

func floppy_umount(args: Array) -> String:
	var mnt = resolve_path("/mnt")
	
	floppyDrive.play_access_sound()
	
	var current_dir := "/" + "/".join(current_path.slice(1, current_path.size()))
	if current_dir.begins_with("/mnt/floppy0"):
		return "floppy: umount: device is busy (currently in use)"
	
	print_to_terminal("writing changes...")
	
	floppyDrive.play_access_sound()
	if floppyDrive.DiskController.ReadOnly:
		print_to_terminal("floppy0: ERROR: Disk is read-only")
	else:
		for i in randi_range(3, 5):
			floppyDrive.play_access_sound()
			await get_tree().create_timer(randf_range(0.5, 1.0)).timeout
		floppyDrive.DiskController.DiskContents = resolve_path("/mnt/floppy0")
		floppyDrive.play_access_sound()

	# Remove from mtab if unmounted
	mtab.erase("/mnt/floppy0")
	var fs_mtab = resolve_path("/etc/mtab")
	fs_mtab.erase("/mnt/floppy0")
	
	if mnt == null:
		return "floppy umount: /mnt does not exist"

	if args.size() == 1:
		args.append("floppy0")

	var target = args[1]

	if not mnt.has(target):
		return "floppy umount: %s is not mounted" % target

	mnt.erase(target)
	return "Unmounted /mnt/%s" % target

func _disk_inserted():
	write_file("/dev/disk0")

func _disk_ejected():
	var mount_ref = resolve_path("/mnt/floppy0")
	if mount_ref != null:
		print_to_terminal("floppy0: WARNING: please unmount before ejecting!")
		mtab.erase("/mnt/floppy0")
		var fs_mtab = resolve_path("/etc/mtab")
		fs_mtab.erase("/mnt/floppy0")
		var mnt = resolve_path("/mnt")
		if mnt and "floppy0" in mnt:
			mnt.erase("floppy0")
	delete_file("/dev/disk0")
