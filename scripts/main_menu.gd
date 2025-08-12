extends Control

@onready var StartButton := $StartButton

var base = preload("res://scenes/base.tscn")

func _ready() -> void:
	StartButton.pressed.connect(_StartButton_pressed)

func _StartButton_pressed():
	get_tree().change_scene_to_packed(base)
