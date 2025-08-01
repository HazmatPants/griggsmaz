extends Node

@onready var SettingBloom := $"../Bloom/CheckButton"
@onready var SettingSSR := $"../SSR/CheckButton"
@onready var SettingReflectionProbes := $"../ReflectionProbes/CheckButton"

@onready var probes = get_tree().get_root().get_node("base/ReflectionProbes")
@onready var wenv = get_tree().get_root().get_node("base/WorldEnvironment")

func _ready():
	SettingBloom.pressed.connect(_UpdateSettings)
	SettingSSR.pressed.connect(_UpdateSettings)
	SettingReflectionProbes.pressed.connect(_UpdateSettings)

func _UpdateSettings():
	GLOBAL.settings["video"]["bloom"] = SettingBloom.button_pressed
	GLOBAL.settings["video"]["ssr"] = SettingSSR.button_pressed
	GLOBAL.settings["video"]["reflection_probes"] = SettingReflectionProbes.button_pressed
	var bloom = GLOBAL.settings["video"]["bloom"] 
	var ssr = GLOBAL.settings["video"]["ssr"]
	var reflectionprobes = GLOBAL.settings["video"]["reflection_probes"]
	wenv.environment.glow_enabled = bloom
	wenv.environment.ssr_enabled = ssr
	probes.visible = reflectionprobes

func apply_settings_to_ui(settings: Dictionary):
	SettingBloom.button_pressed = settings["video"]["bloom"]
	SettingSSR.button_pressed = settings["video"]["ssr"]
	SettingReflectionProbes.button_pressed = settings["video"]["reflection_probes"]
