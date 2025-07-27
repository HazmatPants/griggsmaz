extends Node3D

@onready var spinny = $Spinny

func _process(delta: float) -> void:
	spinny.rotate_y(25 * delta)
