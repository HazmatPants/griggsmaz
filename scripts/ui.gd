extends CanvasLayer

@onready var audio_player := $SFXPlayer

var camera_sound := preload("res://assets/sound/sfx/ui/camera.wav")
var popup_sound := preload("res://assets/sound/sfx/ui/toast_short.wav")

func _process(delta):
	if Input.is_action_just_pressed("hide_hud"):
		visible = not visible
	if Input.is_action_just_pressed("take_screenshot"):
		take_screenshot()

func take_screenshot():
	var image = get_viewport().get_texture().get_image()
	var time = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var dir = "user://screenshots"
	var path = "%s/screenshot_%s.png" % [dir, time]
	
	visible = false

	# Make sure the directory exists
	var dir_access = DirAccess.open("user://")
	if not dir_access.dir_exists("screenshots"):
		dir_access.make_dir("screenshots")

	var error = image.save_png(path)
	if error == OK:
		print("Screenshot saved to: ", ProjectSettings.globalize_path(path))
		show_popup("Screenshot saved to: " + ProjectSettings.globalize_path(path), camera_sound)
	else:
		print("Screenshot failed to save.")
		show_popup("Screenshot failed to save.", popup_sound)
	
	visible = true

func show_popup(text: String, sound: AudioStream=null) -> void:
		var label = Label.new()
		label.text = text
		
		$PopupContainer.add_child(label)
		
		if sound != null:
			playsound(sound)
		
		await get_tree().create_timer(2).timeout
		
		var tween := create_tween()
		tween.tween_property(label, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
		await tween.finished
		
		$PopupContainer.remove_child(label)

func playsound(sound: AudioStream):
	audio_player.stream = sound
	audio_player.play()
