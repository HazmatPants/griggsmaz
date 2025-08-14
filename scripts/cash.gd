extends Node

var chaching := preload("res://assets/sound/sfx/ui/inventory/chaching.ogg")

@onready var amount_label = $"../Node3D/Label3D"

@export var amount: float = 100

func _ready() -> void:
	amount_label.text = str(amount)

func left_click():
	BankManager.cash += amount
	GLOBAL.Player.local_audio_player.stream = chaching
	GLOBAL.Player.local_audio_player.play()
	GLOBAL.Player.drop_object_in_hand()
	get_parent().queue_free()
