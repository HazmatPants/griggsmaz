extends StaticBody3D

@onready var audio_player := $DiskSoundPlayer

var sound_access := [
	preload("res://assets/sound/sfx/disk/hdd/hdd_access1.ogg"),
	preload("res://assets/sound/sfx/disk/hdd/hdd_access2.ogg"),
	preload("res://assets/sound/sfx/disk/hdd/hdd_access3.ogg"),
	preload("res://assets/sound/sfx/disk/hdd/hdd_access4.ogg"),
	preload("res://assets/sound/sfx/disk/hdd/hdd_access5.ogg"),
	preload("res://assets/sound/sfx/disk/hdd/hdd_access6.ogg"),
	preload("res://assets/sound/sfx/disk/hdd/hdd_access7.ogg")
]

@onready var base = GLOBAL.PlayerScene
@onready var power: bool

var base_had_power

func _ready() -> void:
	randomize()
	play_sound()

func play_sound():
	power = base.power
	var time = randf_range(0.5, 4.0)
	await get_tree().create_timer(time).timeout
	if power:
		if randi_range(0, 1) == 1:
			audio_player.play_stream(sound_access[randi_range(0, sound_access.size() - 1)])
	play_sound()

func _process(delta: float) -> void:
	if base_had_power != power:
		$SteamAudioPlayer.playing = power
	
	base_had_power = power
