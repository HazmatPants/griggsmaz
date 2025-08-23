extends Node

@onready var term = get_node("/root/base/Level/Console/MainTerminal")
@onready var player = GLOBAL.Player

var remote_packages: Dictionary = {
	"time": {
		"display_name": "Time",
		"version": "1.0",
		"description": "A single command for checking the time.",
		"commands": {
			"time": func(args): return PKG_time_time(args)
		}
	},
	"bankctl": {
		"display_name": "Bank Control",
		"version": "1.0",
		"description": "A command for managing your credit balance.",
		"commands": {
			"bankctl": func(args): return PKG_bankctl(args)
		}
	}
}

# copies "remote_packages" when you run "pacman update"
var local_package_list: Dictionary = {}

var installed_packages: Dictionary = {}

func PKG_bankctl(args):
	if args.size() == 0:
		term.print_to_terminal("bankctl: missing subcommand, valid subcommands: 'withdraw', 'deposit', 'balance'")
		return

	var subcommand = args[0]

	match subcommand:
		"balance":
			term.print_to_terminal("Balance: %.2f" % BankManager.balance)
		"withdraw":
			if args.size() == 1:
				term.print_to_terminal("bankctl: withdraw: missing amount operand")
				return
			
			var amount = args[1]
			
			if not amount.is_valid_float():
				term.print_to_terminal("bankctl: withdraw: not a number")
				return
			
			amount = float(amount)
			
			if BankManager.withdraw(amount):
				term.print_to_terminal("Withdrew %s. Balance now: %s\n(check dispenser)" % [amount, BankManager.balance])
			else:
				term.print_to_terminal("bankctl: withdraw: insufficient balance")
		"deposit":
				if args.size() == 1:
					term.print_to_terminal("bankctl: deposit: missing amount operand")
					return
				
				var amount = args[1]

				if not amount.is_valid_float():
					term.print_to_terminal("bankctl: deposit: not a number")
					return

				amount = float(amount)

				if BankManager.deposit(amount):
					term.print_to_terminal("Deposited %s. Balance now: %s" % [amount, BankManager.balance])
				else:
					term.print_to_terminal("bankctl: deposit: insufficient balance")

func PKG_time_time(_args):
	return "%s (%s)" % [str(GLOBAL.TIME), GLOBAL.get_time_string()]

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

func get_pkg_info(package: String) -> Dictionary:
	if not local_package_list.has(package):
		return {}
	
	return local_package_list[package]

func get_pkg_info_string(package) -> String:
	if not local_package_list.has(package):
		return ""
	
	var info = get_pkg_info(package)
	
	if info.is_empty():
		return ""
	
	var info_string = ""
	
	info_string += "Name: " + info["display_name"] + "\n"
	info_string += "Version: " + info["version"] + "\n"
	info_string += "Description: " + info["description"] + "\n"
	
	return info_string
