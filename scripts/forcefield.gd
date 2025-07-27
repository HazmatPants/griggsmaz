extends Area3D

@onready var audio_player := $SFXPlayer
@onready var mesh := $MeshInstance3D

@export var alpha_speed: float = 0.9
@export var alpha_min: float = 0.3
@export var alpha_max: float = 0.6

var enter_sound := preload("res://assets/sound/sfx/door/holo_enter.wav")
var exit_sound := preload("res://assets/sound/sfx/door/holo_exit.wav")

var time := 0.0

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	mat = mesh.mesh.material

	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.flags_transparent = true
	mat.albedo_color.a = alpha_max

func _on_body_entered(body):
	audio_player.play_stream(enter_sound, 0.0, -20)

func _on_body_exited(body):
	audio_player.play_stream(exit_sound, 0.0, -20)

var mat: StandardMaterial3D

func _process(delta):
	time += delta
	var sine := sin(time * alpha_speed)
	var normalized := (sine + 1.0) * 0.5
	var alpha = lerp(alpha_min, alpha_max, normalized)

	var color := mat.albedo_color
	color.a = alpha
	mat.albedo_color = color
