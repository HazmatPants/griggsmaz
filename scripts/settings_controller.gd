extends Node

@onready var SettingBloom := $"../Bloom/CheckButton"
@onready var SettingSSR := $"../SSR/CheckButton"

@onready var wenv = get_tree().get_root().get_node("base/WorldEnvironment")

func _ready():
	SettingBloom.pressed.connect(_UpdateSettings)
	SettingSSR.pressed.connect(_UpdateSettings)
	SettingBloom.button_pressed = wenv.environment.glow_enabled
	SettingSSR.button_pressed = wenv.environment.ssr_enabled

func _UpdateSettings():
	wenv.environment.glow_enabled = SettingBloom.button_pressed
	wenv.environment.ssr_enabled = SettingSSR.button_pressed
