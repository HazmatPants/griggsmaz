extends Node3D

@onready var dome := $Node3D/Sphere
@onready var light := $OmniLight3D
@onready var base = get_node("/root/base")
@onready var player := $SteamAudioPlayer

@onready var power: bool

var base_had_power

func _process(delta: float) -> void:
	power = base.power
	light.visible = power
	dome.mesh.material.emission_enabled = power
	if base_had_power != power:
		player.playing = power
	
	base_had_power = power
