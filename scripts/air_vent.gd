extends Node3D

@onready var spinny = $Spinny
@onready var base = get_node("/root/base")
@onready var power: bool
@onready var player := $Vent

var base_had_power

func _process(delta: float) -> void:
	if power:
		spinny.rotate_y(25 * delta)
	power = base.power
	if player != null:
		if base_had_power != power:
			player.playing = power
	
	base_had_power = power
