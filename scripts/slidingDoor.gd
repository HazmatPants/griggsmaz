extends Node3D

@onready var door = $Door
@onready var area = $Area3D
@onready var audio_player = $AudioStreamPlayer3D

var is_open = false
var closed_pos: Vector3
var open_pos: Vector3

var slide_sound = preload("res://assets/sound/sfx/door/doorslide_opening1.ogg")
var close_sound = preload("res://assets/sound/sfx/door/doorshut_1.ogg")
var open_sound = preload("res://assets/sound/sfx/door/doorslide_opened1.ogg")

func _ready():
	# Now door is initialized
	closed_pos = door.position
	open_pos = door.position + Vector3(3, 0, 0)

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player" and not is_open:
		is_open = true

		sound_played_open = false
		sound_played_close = false

		if audio_player:
			audio_player.play_stream(slide_sound, 0.0, 0.0, randf_range(0.95, 1.05))

func _on_body_exited(body):
	if body.name == "Player":
		is_open = false

		sound_played_open = false
		sound_played_close = false

		if audio_player:
			audio_player.play_stream(slide_sound, 0.0, 0.0, randf_range(0.95, 1.05))

var sound_played_open = false
var sound_played_close = false

func _process(delta: float) -> void:
	var target_pos = open_pos if is_open else closed_pos
	door.position = door.position.move_toward(target_pos, 3.0 * delta)

	if door.position.distance_to(open_pos) < 0.01 and is_open and not sound_played_open:
		if audio_player:
			audio_player.play_stream(open_sound, 0.0, 0.0, randf_range(0.95, 1.05))
		sound_played_open = true
		sound_played_close = false

	elif door.position.distance_to(closed_pos) < 0.01 and not is_open and not sound_played_close:
		if audio_player:
			audio_player.play_stream(open_sound, 0.0, 0.0, randf_range(0.95, 1.05))
		sound_played_close = true
		sound_played_open = false
