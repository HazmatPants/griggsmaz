extends Node

@export var min_interval: float = 120.0
@export var max_interval: float = 300.0
@export var quake_duration: float = 6.0
@export var quake_strength: float = 300.0
@export var quake_frequency: float = 0.1


@onready var audio_player := $SFXPlayer
@onready var wenv := $"../WorldEnvironment"
var quake_sound := preload("res://assets/sound/sfx/ambient/earthquake.ogg")

@onready var player = $"../Player"
@onready var particle_emitter = $GPUParticles3D


var default_fog: float
@export var quake_fog_amount: float = 0.3
var quake_fog = default_fog + quake_fog_amount
var fog: float = default_fog

var _is_quaking: bool = false
var _quake_timer: float = 0.0
var _time_until_next: float = 0.0
var _shake_cooldown: float = 0.0
var strength: float

func _ready():
	default_fog = wenv.environment.volumetric_fog_density
	randomize()
	_schedule_next_quake()

func _process(delta):
	if _is_quaking:
		_quake_timer -= delta
		_shake_cooldown -= delta
		wenv.environment.volumetric_fog_density = lerp(wenv.environment.volumetric_fog_density, quake_fog, 0.01)
		player.viewpunch_velocity = lerp(player.viewpunch_velocity, _apply_quake(), 0.01)
		

		if _shake_cooldown <= 0.0:
			_apply_quake()
			_shake_cooldown = quake_frequency

		if _quake_timer <= 0.0:
			_is_quaking = false
			particle_emitter.emitting = false
			_schedule_next_quake()
	else:
		wenv.environment.volumetric_fog_density = lerp(wenv.environment.volumetric_fog_density, default_fog, 0.01)
		_time_until_next -= delta
		if _time_until_next <= 0.0:
			_start_quake()

func _schedule_next_quake():
	_time_until_next = randf_range(min_interval, max_interval)

func _start_quake():
	print("Starting earthquake")
	strength = quake_strength
	particle_emitter.emitting = true
	audio_player.stream = quake_sound
	audio_player.play()
	_is_quaking = true
	_quake_timer = quake_duration
	_shake_cooldown = 0.0

func _apply_quake():
	
	var direction = Vector3(
		randf_range(-90.0, 90.0),
		randf_range(-90.0, 90.0),
		randf_range(-90.0, 90.0)
	).normalized()

	var velocity_punch = direction * randf_range(0.0, 20.0) * strength
	strength = lerp(strength, 0.0, 0.003)
	print(strength)
	
	return velocity_punch
