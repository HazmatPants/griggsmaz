extends Node3D

@onready var audio_player: SteamAudioPlayer = $SFXPlayer
@onready var spinny := $Spinny

@onready var light1: SpotLight3D = $Spinny/Light1
@onready var light2: SpotLight3D = $Spinny/Light2

func _process(delta: float) -> void:
	var alarm = GLOBAL.alarm
	if alarm:
		light1.visible = alarm
		light2.visible = alarm
		if not audio_player.playing:
			audio_player.play()
		
		spinny.rotate_y(15 * delta)
	else:
		if audio_player.playing:
			audio_player.stop()
