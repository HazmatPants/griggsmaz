extends Node

@onready var term := get_node("/root/base/Level/Console/MainTerminal")
@onready var player = get_node("/root/base/Player")

var remote_packages: Dictionary = {
	"time": {
		"display_name": "Time",
		"version": "1.0",
		"commands": {
			"time": func(args): return PKG_time_time(args)
		}
	},
	"debug-tools": {
		"display_name": "Debug Tools",
		"version": "1.0",
		"commands": {
			"debug": func(args): return PKG_debug(args)
		}
	}
}

# copies "remote_packages" when you run "pacman update"
var local_package_list: Dictionary = {}

var installed_packages: Dictionary = {}

var external_commands: Dictionary = {}

func PKG_time_time(_args):
	return "%s (%s)" % [str(GLOBAL.TIME), GLOBAL.get_time_string()]

func PKG_debug(args):
	if args.size() == 0:
		term.print_to_terminal("debug: missing subcommand, valid subcommands: 'time'")
		return

	var subcommand = args[0]

	match subcommand:
		"time":
			if args.size() == 1:
				term.print_to_terminal("debug: time: missing subsubcommand")
				return
			var subsubcommand = args[1]
			match subsubcommand:
				"set":
					if args.size() == 1:
						term.print_to_terminal("debug: time: set: missing target time")
						return
					
					GLOBAL.TIME = args[2]
				"add":
					if args.size() == 1:
						term.print_to_terminal("debug: time: add: missing target time")
						return
					
					GLOBAL.TIME += args[2]
				"get":
					var time = GLOBAL.TIME
					var normalized_time = GLOBAL.get_normalized_time()
					var light_energy = str(sin(PI * normalized_time))
					var sun_rot = get_node("/root/base/Sun").rotation_degrees.x
					term.print_to_terminal("Time: %s\nNormalized time: %s\nLight energy: %s\nSun rotation: %s" % [time, normalized_time, light_energy, sun_rot])
				_:
					term.print_to_terminal("debug: time: invalid subsubcommand, valid subsubcommands: 'set', 'add', 'get'")
		"player":
			var subsubcommand = args[1]
			match subsubcommand:
				"print_inv":
					term.print_to_terminal(str(player.inventory.inventory))
					print(player.inventory.inventory)
		_:
			term.print_to_terminal("debug: invalid subcommand, valid subcommands: 'time'")

func update_package_list() -> void:
	term.print_to_terminal("Contacting package server...")
	await get_tree().create_timer(randf_range(1.0, 3.0)).timeout

	if local_package_list.hash() == remote_packages.hash():
		term.print_to_terminal("Package list is up to date.")
		term.print_to_terminal("There is nothing to do.")
		return

	var pkg_diff: float = max(remote_packages.size() - local_package_list.size(), 0)
	term.print_to_terminal("Downloading package list...")
	await get_tree().create_timer(randf_range(1.0, pkg_diff * 1.3)).timeout

	local_package_list = remote_packages.duplicate(true)
	term.print_to_terminal("Done.")

func install_package(package: String) -> void:
	if not local_package_list.has(package):
		term.print_to_terminal("Package '%s' not found" % package)
		return
	
	if installed_packages.has(package):
		term.print_to_terminal("Package '%s' is already installed" % package)
		term.print_to_terminal("There is nothing to do.")
		return
	
	term.print_to_terminal("Contacting package server...")
	await get_tree().create_timer(randf_range(1.0, 3.0)).timeout
	
	term.print_to_terminal("Downloading '%s'" % package)
	await get_tree().create_timer(randf_range(1.0, 5.0)).timeout
	var pkg_data: Dictionary = local_package_list[package].duplicate(true)
	
	term.print_to_terminal("Installing '%s'" % package)
	await get_tree().create_timer(randf_range(1.0, 3.0)).timeout
	
	for command in pkg_data["commands"].keys():
		if external_commands.has(command):
			term.print_to_terminal("Warning: Command '%s' already exists, skipping..." % command)
		else:
			external_commands[command] = pkg_data["commands"][command]
	
	installed_packages[package] = pkg_data
	term.print_to_terminal("Done.")
