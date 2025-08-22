extends MeshInstance3D

func _process(_delta):
	var sun_dir = -$"../Sun".global_transform.basis.y
	mesh.material.set_shader_parameter("light_direction", sun_dir.normalized())
