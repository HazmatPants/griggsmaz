extends SpotLight3D

var sfx_flashlight := preload("res://assets/sound/sfx/player/flashlight.wav")

func toggle_light():
	visible = !visible
	$AudioStreamPlayer.stream = sfx_flashlight
	$AudioStreamPlayer.play()
