extends DirectionalLight3D

func _process(delta: float) -> void:
	var normalized_time := GLOBAL.get_normalized_time()
	var angle = lerp(-90.0, 270.0, normalized_time)
	rotation_degrees.x = angle
	light_energy = sin(PI * normalized_time)
