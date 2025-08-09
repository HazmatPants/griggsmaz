extends Control

@onready var player = get_node("/root/base/Player")
@onready var frontRay = get_node("/root/base/Player/Camera3D/InteractRay")
@onready var playerGUI = get_node("/root/base/PlayerGUI")
@onready var inventory = get_node("/root/base/Player/Inventory")
@onready var invList = $HBox/ListPanel/MarginContainer/List
@onready var invProperties = $HBox/Control/MarginContainer/VBoxContainer
@onready var context_menu: PopupMenu = $PopupMenu

var selected_item_id: int = -1

func _ready() -> void:
	visible = false
	
	# Setup context menu
	context_menu.clear()
	context_menu.add_item("Use", 0)
	context_menu.add_item("Drop", 1)
	context_menu.add_item("Hold", 2)
	context_menu.id_pressed.connect(_on_context_menu_pressed)

func refresh_inventory():
	$Weight.text = "%s/%s" % [
		inventory.get_total_weight(),
		inventory.max_weight
	]
	
	# Clear list
	for node in invList.get_children():
		node.queue_free()
	
	# Rebuild list
	for id in inventory.inventory.keys():
		var item_data = inventory.inventory[id]
		
		var container = MarginContainer.new()
		var margin = 10
		add_theme_constant_override("margin_top", margin)
		add_theme_constant_override("margin_left", margin)
		add_theme_constant_override("margin_bottom", margin)
		add_theme_constant_override("margin_right", margin)
		container.name = str(id)
		
		
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(0, 30)
		panel.modulate = Color(0.2, 0.2, 0.3, 1)
		
		var label_name = Label.new()
		label_name.text = "%s | %.1f" % [pascal_to_spaces(item_data["name"]), item_data["weight"]]
		label_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		container.add_child(panel)
		container.add_child(label_name)
		invList.add_child(container)
		
		# Left click → select
		panel.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed:
				if event.button_index == MOUSE_BUTTON_LEFT:
					show_item_details(id)
				elif event.button_index == MOUSE_BUTTON_RIGHT:
					selected_item_id = id
					context_menu.set_position(get_global_mouse_position())
					context_menu.popup()
		)

func show_item_details(item_id: int):
	var item_data = inventory.inventory[item_id]
	invProperties.get_node("Name").text = pascal_to_spaces(item_data["name"])
	invProperties.get_node("Weight").text = "Weight: %s" % item_data["weight"]

func _on_context_menu_pressed(id: int):
	if selected_item_id == -1:
		return
	
	match id:
		0: # Use
			print("Using:", inventory.inventory[selected_item_id]["name"])
			playerGUI.show_popup("not implemented", playerGUI.sfx_popup)
		1: # Drop
			drop_item(selected_item_id)
		2: # Hold
			hold_item(selected_item_id)

func hold_item(id: int):
	inventory.hold_item(id)
	
	refresh_inventory()

func drop_item(id: int):
	inventory.drop_item(id)
	
	refresh_inventory()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		if GLOBAL.CanPause:
			refresh_inventory()
			visible = not visible
			player.input_enabled = not visible
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED

func pascal_to_spaces(text: String) -> String:
	var result := ""
	for i in range(text.length()):
		var char: String = text[i]
		if i > 0 and char.to_upper() == char:
			result += " "
		result += char
	return result
