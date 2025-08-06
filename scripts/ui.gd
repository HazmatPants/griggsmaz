extends CanvasLayer

@onready var audio_player := $SFXPlayer
@onready var player := get_node("/root/base/Player")
@onready var low_health_overlay := $LowHealthOverlay
@onready var blur_overlay := $BlurRect
#@onready var wenv: WorldEnvironment = get_node("/root/base/WorldEnvironment/")
#@onready var light = get_node("/root/base/Player/Camera3D/NVGLight")

var sfx_camera := preload("res://assets/sound/sfx/ui/camera.wav")
var sfx_popup := preload("res://assets/sound/sfx/ui/toast_short.wav")

#var sfx_nvg_on := preload("res://assets/sound/sfx/player/night_vision_on.wav")
#var sfx_nvg_off := preload("res://assets/sound/sfx/player/night_vision_off.wav")

#var nvg_on = false

var low_health_threshold := 0.5

func _process(delta):
	if Input.is_action_just_pressed("hide_hud"):
		visible = not visible
	if Input.is_action_just_pressed("take_screenshot"):
		take_screenshot()
	
	var health_ratio = player.health / player.max_health
	if health_ratio <= low_health_threshold:
		low_health_overlay.visible = true
		low_health_overlay.modulate.a = lerp(0.0, 0.4, 1.0 - (health_ratio / low_health_threshold))
		blur_overlay.material.set_shader_parameter("direction", Vector2(1.0, 0.0) * (1.0 - (health_ratio / low_health_threshold)))
	else:
		low_health_overlay.visible = false
	
	#if Input.is_action_just_pressed("toggle_nvg"):
		#nvg_on = !nvg_on
		#$Vignette.visible = nvg_on
		#$NVGRect.visible = nvg_on
		#light.visible = nvg_on
		#wenv.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR if nvg_on else Environment.AMBIENT_SOURCE_DISABLED
		#wenv.environment.ambient_light_color = Color(0, 1, 1 ,1)
		#wenv.environment.ambient_light_energy = 50.0
		#audio_player.stream = sfx_nvg_on if nvg_on else sfx_nvg_off
		#audio_player.play()
	
	#if nvg_on:
		#var target_light_energy = 1.8 if nvg_on else 0.0
		#wenv.environment.ambient_light_energy = lerp(wenv.environment.ambient_light_energy, target_light_energy, 0.05)

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
		show_popup("Screenshot saved to: " + ProjectSettings.globalize_path(path), sfx_camera)
	else:
		print("Screenshot failed to save.")
		show_popup("Screenshot failed to save.", sfx_popup)
	
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
