extends Node3D

@onready var door1 = $Door1
@onready var door2 = $Door2
@onready var area = $Area3D
@onready var audio_player = $SFXPlayer
@onready var audio_player2 = $SFXPlayer2

@onready var player = get_tree().get_root().get_node("base/Player")

@export var required_keycard_level: int = 0

var is_open = false

var closed_pos1: Vector3
var open_pos1: Vector3
var closed_pos2: Vector3
var open_pos2: Vector3

var slide_sound = preload("res://assets/sound/sfx/door/doorslide_opening1.ogg")
var close_sound = preload("res://assets/sound/sfx/door/doorshut_1.ogg")
var open_sound = preload("res://assets/sound/sfx/door/doorslide_opened1.ogg")
var locked_sound = preload("res://assets/sound/sfx/door/cmb_button_locked.ogg")
var button_sound = preload("res://assets/sound/sfx/ui/accept.ogg")

var sound_played_open = false
var sound_played_close = true

func _ready():
	closed_pos1 = door1.position
	closed_pos2 = door2.position

	open_pos1 = closed_pos1 + Vector3(-1.5, 0, 0)
	open_pos2 = closed_pos2 + Vector3(1.5, 0, 0)

func interact():
	if player.object_in_hand != null:
		if player.object_in_hand.name.begins_with("Keycard"):
			if player.object_in_hand.get_meta("access_level") >= required_keycard_level:
				is_open = not is_open

				sound_played_open = false
				sound_played_close = false
				audio_player2.play_stream(button_sound)

				audio_player.play_stream(slide_sound, 0.0, 0.0, randf_range(0.95, 1.05))
			else:
				audio_player2.play_stream(locked_sound, 0.0, 0.0, randf_range(0.95, 1.05))

func _process(delta: float) -> void:
	var speed = 3.0 * delta

	var target_pos1 = open_pos1 if is_open else closed_pos1
	var target_pos2 = open_pos2 if is_open else closed_pos2

	door1.position = door1.position.move_toward(target_pos1, speed)
	door2.position = door2.position.move_toward(target_pos2, speed)

	var doors_open = (
		door1.position.distance_to(open_pos1) < 0.01 and
		door2.position.distance_to(open_pos2) < 0.01
	)
	var doors_closed = (
		door1.position.distance_to(closed_pos1) < 0.01 and
		door2.position.distance_to(closed_pos2) < 0.01
	)

	if doors_open and is_open and not sound_played_open:
		if audio_player:
			audio_player.play_stream(open_sound, 0.0, 0.0, randf_range(0.95, 1.05))
			audio_player.play()
		sound_played_open = true
		sound_played_close = false

	elif doors_closed and not is_open and not sound_played_close:
		if audio_player:
			audio_player.play_stream(close_sound, 0.0, 0.0, randf_range(0.95, 1.05))
		sound_played_close = true
		sound_played_open = false
