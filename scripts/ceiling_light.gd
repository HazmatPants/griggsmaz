extends Node3D

@onready var dome := $Node3D/Sphere
@onready var light := $OmniLight3D
@onready var base = get_node("/root/base")
@onready var player := $SteamAudioPlayer

var power: bool
var base_had_power

func _ready() -> void:
	light.distance_fade_enabled = true
	flicker()

func _process(_delta: float) -> void:
	power = base.power
	set_light(power)
	if base_had_power != power:
		player.playing = power
	
	base_had_power = power
	light.shadow_enabled = GLOBAL.settings["video"]["shadows"]

func set_light(state: bool):
	light.visible = state
	dome.mesh.material.emission_enabled = state

func flicker():
	if power:
		if randi_range(0, 50) == 0:
			set_light(false)
			await get_tree().create_timer(randf() / 10).timeout
			set_light(true)
	await get_tree().create_timer(randf_range(1.0, 4.0)).timeout
	flicker()
