extends Node3D

@onready var base = get_node("/root/base/")
@onready var audio_player := $SFXPlayer

var sfx_lever := preload("res://assets/sound/sfx/buttons/lever8.wav")

func interact():
	audio_player.play_stream(sfx_lever)
	await get_tree().create_timer(0.3).timeout
	base.power = not base.power
