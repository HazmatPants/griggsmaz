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
			get_tree().create_timer(1).free()
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
				"get_rad":
					term.print_to_terminal(str("Accumulated Dose: %s\nDose Rate: %s" % [player.accumulated_dose, player.dose_rate]))
					print("Accumulated Dose: %s\nDose Rate: %s" % [player.accumulated_dose, player.dose_rate])
				_:
					term.print_to_terminal("debug: player: invalid subsubcommand")
		_:
			term.print_to_terminal("debug: invalid subcommand, valid subcommands: 'time'")

func update_package_list() -> void:
	term.print_to_terminal("Contacting package server...")
	await term.wait_sec(randf_range(1.0, 3.0))
	if term.SIGINT:
		term.print_to_terminal("Interrupted")
		return

	if local_package_list.hash() == remote_packages.hash():
		term.print_to_terminal("Package list is up to date.")
		term.print_to_terminal("There is nothing to do.")
		return

	var pkg_diff: float = max(remote_packages.size() - local_package_list.size(), 0)
	term.print_to_terminal("Downloading package list...")
	await term.wait_sec(randf_range(1.0, pkg_diff * 1.3))
	if term.SIGINT:
		term.print_to_terminal("Interrupted")
		return
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
	await term.wait_sec(randf_range(1.0, 3.0))
	if term.SIGINT:
		term.print_to_terminal("Interrupted")
		return
	
	term.print_to_terminal("Downloading '%s'" % package)
	await term.wait_sec(randf_range(1.0, 5.0))
	if term.SIGINT:
		term.print_to_terminal("Interrupted")
		return
	var pkg_data: Dictionary = local_package_list[package].duplicate(true)
	
	term.print_to_terminal("Installing '%s'" % package)
	await term.wait_sec(randf_range(1.0, 3.0))
	if term.SIGINT:
		term.print_to_terminal("Interrupted")
		return
	
	var usrbin = term.resolve_path("/usr/bin")
	for command in pkg_data["commands"].keys():
		if usrbin.has(command):
			term.print_to_terminal("Warning: Command '%s' already exists, skipping..." % command)
		else:
			usrbin[command] = pkg_data["commands"][command]
	
	installed_packages[package] = pkg_data
	term.print_to_terminal("Done.")
