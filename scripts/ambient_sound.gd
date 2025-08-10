extends AudioStreamPlayer

@export var sound_list: Array[AudioStream] = [
	preload("res://assets/sound/sfx/ambient/eep1.mp3"),
	preload("res://assets/sound/sfx/ambient/eep2.mp3"),
	preload("res://assets/sound/sfx/ambient/eep_call_1.mp3"),
	preload("res://assets/sound/sfx/ambient/eep_call_2.mp3"),
	preload("res://assets/sound/sfx/ambient/eep_call_3.mp3"),
	preload("res://assets/sound/sfx/ambient/eep_call_4.mp3"),
	preload("res://assets/sound/sfx/ambient/eep_ping_1.mp3"),
	preload("res://assets/sound/sfx/ambient/eep_ping_2.mp3"),
	preload("res://assets/sound/sfx/ambient/eep_ping_3.mp3"),
	preload("res://assets/sound/sfx/ambient/eep_ping_4.mp3"),
]
@export_range(10, 600, 1) var min_delay_seconds := 30
@export_range(10, 600, 1) var max_delay_seconds := 90

func _ready():
	randomize()
	_play_random_ambient_sound()

func _play_random_ambient_sound():
	if sound_list.is_empty():
		push_warning("No sounds in sound_list.")
		return

	var wait_time = randf_range(min_delay_seconds, max_delay_seconds)
	var sound = sound_list[randi() % sound_list.size()]
	await get_tree().create_timer(wait_time).timeout

	stream = sound
	play()

	_play_random_ambient_sound()
