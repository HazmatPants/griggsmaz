extends Node3D

var sfx_power_off = preload("res://assets/sound/sfx/ambient/stationTurnoff.ogg")

var power: bool = true
var base_had_power: bool = power

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SEMICOLON:
			power = not power

func _process(delta: float) -> void:
	if base_had_power and not power:
		$AmbientSound2.stream = sfx_power_off
		$AmbientSound2.play()

	base_had_power = power
