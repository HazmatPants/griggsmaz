extends Node3D

@onready var door1 = $Door1
@onready var door2 = $Door2
@onready var area = $Area3D
@onready var local_audio_player = $AudioStreamPlayer
@onready var audio_player = $SFXPlayer
@onready var audio_player2 = $SFXPlayer2

# Movement settings
@export var locked = false

enum DoorType { AUTOMATIC, MANUAL }

@export_enum("Automatic", "Manual")
var door_type: int = DoorType.AUTOMATIC

var is_open = false

var closed_pos1: Vector3
var open_pos1: Vector3
var closed_pos2: Vector3
var open_pos2: Vector3

var slide_sound = preload("res://assets/sound/sfx/door/doorslide_opening1.ogg")
var close_sound = preload("res://assets/sound/sfx/door/doorshut_1.ogg")
var open_sound = preload("res://assets/sound/sfx/door/doorslide_opened1.ogg")
var locked_sound = preload("res://assets/sound/sfx/door/cmb_button_locked.ogg")
var button_sound = preload("res://assets/sound/sfx/door/button.ogg")

var sound_played_open = false
var sound_played_close = true

@onready var LED = $Panel/LED
var LED_locked_color := Color(1, 0, 0, 1)
var LED_unlocked_color := Color(0, 1, 0, 1)

func _ready():
	# Save original positions
	closed_pos1 = door1.position
	closed_pos2 = door2.position

	open_pos1 = closed_pos1 + Vector3(-1.5, 0, 0)
	open_pos2 = closed_pos2 + Vector3(1.5, 0, 0)
	
	if door_type == DoorType.AUTOMATIC:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

func interact():
	if door_type == DoorType.MANUAL:
		if not locked:
			is_open = not is_open

			sound_played_open = false
			sound_played_close = false
			local_audio_player.stream = button_sound
			local_audio_player.play()

			if audio_player:
				audio_player.play_stream(slide_sound, 0.0, 0.0, randf_range(0.95, 1.05))
		else:
			if audio_player:
				print("door is locked")
				local_audio_player.stream = locked_sound
				local_audio_player.play()

func _on_body_entered(body):
	if body.name == "Player" and not is_open:
		if not locked:
			is_open = true

			sound_played_open = false
			sound_played_close = false

			if audio_player:
				audio_player.play_stream(slide_sound, 0.0, 0.0, randf_range(0.95, 1.05))
		else:
			if audio_player:
				local_audio_player.stream = locked_sound
				local_audio_player.play()
			
func _on_body_exited(body):
	if body.name == "Player":
		if not locked:
			is_open = false

			sound_played_open = false
			sound_played_close = false

			if audio_player:
				audio_player.play_stream(slide_sound, 0.0, 0.0, randf_range(0.95, 1.05))

func _process(delta: float) -> void:
	var speed = 3.0 * delta

	var target_pos1 = open_pos1 if is_open else closed_pos1
	var target_pos2 = open_pos2 if is_open else closed_pos2

	door1.position = door1.position.move_toward(target_pos1, speed)
	door2.position = door2.position.move_toward(target_pos2, speed)

	# Check if both doors have reached their target
	var doors_open = (
		door1.position.distance_to(open_pos1) < 0.01 and
		door2.position.distance_to(open_pos2) < 0.01
	)
	var doors_closed = (
		door1.position.distance_to(closed_pos1) < 0.01 and
		door2.position.distance_to(closed_pos2) < 0.01
	)

	if doors_open and is_open and not sound_played_open:
		if not locked:
			if audio_player:
				audio_player.play_stream(open_sound, 0.0, 0.0, randf_range(0.95, 1.05))
				audio_player.play()
			sound_played_open = true
			sound_played_close = false

	elif doors_closed and not is_open and not sound_played_close:
		if not locked:
			if audio_player:
				audio_player.play_stream(close_sound, 0.0, 0.0, randf_range(0.95, 1.05))
			sound_played_close = true
			sound_played_open = false

func toggle_lock():
	local_audio_player.stream = button_sound
	local_audio_player.play()
	locked = not locked
	LED.mesh.material.emission = LED_locked_color if locked else LED_unlocked_color
