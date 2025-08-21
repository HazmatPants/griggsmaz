extends Node3D

@onready var frontRay = get_parent().get_node("Camera3D/InteractRay")

@export var inventory: Dictionary = {}
@export var max_weight: float = 100.0
var next_item_id: int = 0

# Item format:
# {
#    id: {
#        "name": String,
#        "weight": float,
#        "object": RigidBody3D
#    }
# }

func pickup_item(object: RigidBody3D, itemname: String, weight: float) -> bool:
	object.freeze = true
	object.visible = false
	object.global_transform = global_transform
	object.get_parent().remove_child(object)
	add_child(object)
	return try_add_item(itemname, weight, object)

func hold_item(id: int):
	if not inventory.has(id):
		return
	
	var base = GLOBAL.PlayerScene
	var player = GLOBAL.Player
	var object: RigidBody3D = inventory[id]["object"]
	if player.object_in_hand:
		var playerGUI = get_node("/root/base/PlayerGUI")
		playerGUI.show_popup("Already holding something!", playerGUI.sfx_popup)
		return
	
	# Reparent back into the world
	object.get_parent().remove_child(object)
	base.add_child(object)
	
	object.freeze = false
	object.visible = true
	player.object_in_hand = object
	
	# Remove from inventory
	remove_item(id)

func drop_item(id: int):
	if not inventory.has(id):
		return
	
	var base = get_node("/root/base")
	var object: RigidBody3D = inventory[id]["object"]
	
	# Reparent back into the world
	object.get_parent().remove_child(object)
	base.add_child(object)
	
	# Position in front of player
	if frontRay.is_colliding():
		object.global_transform.origin = frontRay.get_collision_point()
	else:
		object.global_transform.origin = frontRay.to_global(frontRay.target_position)
	
	# Turn physics back on
	object.freeze = false
	object.visible = true
	object.collider.disabled = false
	object.gravity_scale = 1.0
	
	# Remove from inventory
	remove_item(id)

func try_add_item(itemname: String, weight: float, object: RigidBody3D) -> bool:
	if can_add_weight(weight):
		var data = {
			"name": itemname,
			"weight": weight,
			"object": object
		}
		inventory[next_item_id] = data
		next_item_id += 1
		print("added item '%s' to inventory. total weight now: %s" % [itemname, str(get_total_weight())])
		return true
	return false

func remove_item(id: int) -> bool:
	if inventory.has(id):
		inventory.erase(id)
		return true
	return false

func get_total_weight() -> float:
	var total: float = 0.0
	for data in inventory.values():
		total += data["weight"]
	return total

func can_add_weight(weight: float) -> bool:
	return get_total_weight() + weight <= max_weight
