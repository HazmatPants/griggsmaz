extends Node3D

@onready var base = GLOBAL.PlayerScene
@onready var audio_player := $SFXPlayer
@onready var lever := $LeverPivot

var sfx_lever := preload("res://assets/sound/sfx/buttons/lever8.wav")

var lever_state: bool = true

func interact():
	lever_state = not lever_state
	audio_player.play_stream(sfx_lever)
	await get_tree().create_timer(0.3).timeout
	base.power = not base.power

func _process(_delta: float) -> void:
	if lever_state:
		lever.rotation.x = lerp_angle(lever.rotation.x, deg_to_rad(-87), 0.2)
	else:
		lever.rotation.x = lerp_angle(lever.rotation.x, deg_to_rad(87), 0.2)
