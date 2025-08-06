extends CanvasLayer

var is_paused := false

@onready var playerGUI = get_tree().get_root().get_node("base/PlayerGUI")

@onready var ResumeButton := $BG/ButtonContainer/ResumeButton
@onready var SettingsButton := $BG/ButtonContainer/SettingsButton
@onready var QuitButton := $BG/ButtonContainer/QuitButton
@onready var SettingsContainer := $Settings
@onready var SettingsCloseButton := $Settings/CloseButton
@onready var SettingsController := $Settings/SettingsContainer/SettingsController

func _ready():
	visible = false
	SettingsContainer.visible = false
	ResumeButton.pressed.connect(_on_resumebutton_pressed)
	SettingsButton.pressed.connect(_on_settingsbutton_pressed)
	QuitButton.pressed.connect(_on_quitbutton_pressed)
	SettingsCloseButton.pressed.connect(_on_settingsclosebutton_pressed)
	
	GLOBAL.settings = get_settings()
	SettingsController.apply_settings_to_ui(GLOBAL.settings)
	SettingsController._UpdateSettings()
	
	apply_settings(GLOBAL.settings)

func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		if GLOBAL.CanPause:
			_toggle_pause()

func _toggle_pause():
	is_paused = not is_paused
	get_tree().paused = is_paused
	visible = is_paused
	playerGUI.visible = not is_paused
	
	if not is_paused:
		if SettingsContainer.visible:
			save_dict_as_config(GLOBAL.settings, "user://settings.cfg")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		SettingsContainer.visible = false
		Input.flush_buffered_events()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		ResumeButton.grab_focus()

func _on_resumebutton_pressed():
	is_paused = false
	get_tree().paused = is_paused
	visible = is_paused
	playerGUI.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.flush_buffered_events()

func _on_settingsbutton_pressed():
	SettingsContainer.visible = true

func _on_settingsclosebutton_pressed():
	save_dict_as_config(GLOBAL.settings, "user://settings.cfg")
	SettingsContainer.visible = false

func _on_quitbutton_pressed():
	get_tree().quit()

func apply_settings(settings: Dictionary):
	SettingsController.SettingBloom.button_pressed = get_nested(settings, ["video", "bloom"], false)
	SettingsController.SettingSSR.button_pressed = get_nested(settings, ["video", "ssr"], false)
	SettingsController.SettingReflectionProbes.button_pressed = get_nested(settings, ["video", "reflection_probes"], false)
	SettingsController.SettingShadowMode.button_pressed = get_nested(settings, ["video", "shadows"], false)

func get_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK:
		print("Failed to load config")
		return GLOBAL.settings
	else:
		var result = {}
		for section in config.get_sections():
			result[section] = {}
			for key in config.get_section_keys(section):
				result[section][key] = config.get_value(section, key)
		return result

func get_nested(dict: Dictionary, keys: Array, default = null):
	var current = dict
	for key in keys:
		if current is Dictionary and current.has(key):
			current = current[key]
		else:
			return default
	return current

func save_dict_as_config(data: Dictionary, path: String) -> int:
	print("Saving settings: ", data)
	var config = ConfigFile.new()

	for section in data.keys():
		var section_data = data[section]
		if section_data is Dictionary:
			for key in section_data.keys():
				config.set_value(section, key, section_data[key])
		else:
			push_warning("Skipping section '%s': not a Dictionary" % section)

	var err = config.save(path)
	if err != OK:
		push_error("Failed to save config file: %s" % path)
		return err
	print("Saved settings:")
	return err
