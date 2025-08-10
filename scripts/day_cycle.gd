extends DirectionalLight3D

func _process(delta: float) -> void:
	var normalized_time := GLOBAL.get_normalized_time() # 0..1

	# Map 0..1 -> -90..90 degrees (sun stays above horizon)
	var angle = lerp(-90.0, 90.0, normalized_time)
	rotation_degrees.x = -angle

	# Fade in/out light smoothly
	light_energy = max(0.0, sin(PI * normalized_time))
