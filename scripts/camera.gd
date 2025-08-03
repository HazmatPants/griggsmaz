extends Camera3D

@export var base_fov := 85.0
@export var zoom_fov := 40.0
@export var zoom_speed := 10.0

@onready var local_audio_player: AudioStreamPlayer = $"../LocalSFXPlayer"
@onready var flashlight = $SpotLight3D

var sfx_flashlight := preload("res://assets/sound/sfx/player/flashlight1.wav")

func _ready() -> void:
	flashlight.visible = false
	fov = base_fov

func _process(delta: float) -> void:
	if Input.is_action_pressed("zoom"):
		fov = lerp(fov, zoom_fov, zoom_speed * delta)
	else:
		fov = lerp(fov, base_fov, zoom_speed * delta)
	
	if Input.is_action_just_pressed("flashlight"):
		flashlight.visible = not flashlight.visible
		local_audio_player.stream = sfx_flashlight
		local_audio_player.play()
