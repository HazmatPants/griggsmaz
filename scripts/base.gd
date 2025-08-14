extends Node3D

@onready var powerbox = $PowerBox

var sfx_power_off = preload("res://assets/sound/sfx/ambient/stationTurnoff.ogg")

var power: bool = true
var base_had_power: bool = power

signal PowerOn
signal PowerOff

func _ready() -> void:
	GLOBAL.PlayerGUI = get_node("PlayerGUI") 
	try_blackout()

func _process(_delta: float) -> void:
	if base_had_power and not power:
		$AmbientSound2.stream = sfx_power_off
		$AmbientSound2.play()
		PowerOff.emit()
	if not base_had_power and power:
		PowerOn.emit()

	base_had_power = power

func try_blackout():
	if power:
		if randi_range(0, 100) == 0:
			power = false
			powerbox.lever_state = false
	await get_tree().create_timer(60).timeout
	try_blackout()
