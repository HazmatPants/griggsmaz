extends Control

@onready var StartButton := $StartButton
@onready var Title := $Title
@onready var Name := $Name
@onready var ap := $AudioStreamPlayer

var base = preload("res://scenes/space_station.tscn")

var fadeTitle := false
var fadeName := true

func _ready() -> void:
	StartButton.pressed.connect(_StartButton_pressed)

	Title.modulate.a = 0
	StartButton.modulate.a = 0
	Name.modulate.a = 0

	ap.play()
	
	start_seq()

func start_seq():
	await get_tree().create_timer(5).timeout
	
	fadeTitle = true

func _StartButton_pressed():
	get_tree().change_scene_to_packed(base)

func _process(delta: float) -> void:
	if fadeTitle == true:
		StartButton.modulate.a = lerp(StartButton.modulate.a, 1.0, 0.7 * delta)
		Title.modulate.a = lerp(Title.modulate.a, 1.0, 0.7 * delta)
	if fadeName == true:
		Name.modulate.a = lerp(Name.modulate.a, 1.0, 0.4 * delta)
	if Title.modulate.a > 0.8:
		StartButton.disabled = false
