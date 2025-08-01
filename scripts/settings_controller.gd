extends Node

@onready var SettingBloom := $"../Bloom/CheckButton"
@onready var SettingSSR := $"../SSR/CheckButton"
@onready var SettingReflectionProbes := $"../ReflectionProbes/CheckButton"
@onready var SettingShadowMode := $"../ShadowMode/OptionButton"

@onready var probes = get_tree().get_root().get_node("base/ReflectionProbes")
@onready var sun = get_tree().get_root().get_node("base/Sun")
@onready var wenv = get_tree().get_root().get_node("base/WorldEnvironment")

func _ready():
	SettingBloom.pressed.connect(_UpdateSettings)
	SettingSSR.pressed.connect(_UpdateSettings)
	SettingReflectionProbes.pressed.connect(_UpdateSettings)
	SettingShadowMode.item_selected.connect(_UpdateSettings)

func _UpdateSettings(shadow_mode: int=GLOBAL.settings["video"]["shadow_mode"]):
	GLOBAL.settings["video"]["bloom"] = SettingBloom.button_pressed
	GLOBAL.settings["video"]["ssr"] = SettingSSR.button_pressed
	GLOBAL.settings["video"]["reflection_probes"] = SettingReflectionProbes.button_pressed
	GLOBAL.settings["video"]["shadow_mode"] = shadow_mode
	wenv.environment.glow_enabled = GLOBAL.settings["video"]["bloom"] 
	wenv.environment.ssr_enabled = GLOBAL.settings["video"]["ssr"]
	probes.visible = GLOBAL.settings["video"]["reflection_probes"]
	sun.directional_shadow_mode = GLOBAL.settings["video"]["shadow_mode"]

func apply_settings_to_ui(settings: Dictionary):
	SettingBloom.button_pressed = settings["video"]["bloom"]
	SettingSSR.button_pressed = settings["video"]["ssr"]
	SettingReflectionProbes.button_pressed = settings["video"]["reflection_probes"]
	SettingShadowMode.selected = settings["video"]["shadow_mode"]
