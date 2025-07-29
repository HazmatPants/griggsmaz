extends Control

@onready var tooltip := $Tooltip

func _ready():
	tooltip.visible = false
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)
	tooltip.top_level = true
	tooltip.custom_minimum_size = Vector2(500.0, 0.0)
	tooltip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	tooltip.label_settings = LabelSettings.new()
	tooltip.label_settings.shadow_size = 4
	tooltip.label_settings.shadow_color = Color(0, 0, 0, 0.5)
	tooltip.label_settings.shadow_offset = Vector2(2.0, 2.0)

func _on_mouse_enter():
	tooltip.visible = true

func _on_mouse_exit():
	tooltip.visible = false

func _process(delta):
	if tooltip.visible:
		var pos = get_global_mouse_position() + Vector2(25.0, 0.0)
		var _size = tooltip.size
		var screen_size = get_viewport_rect().size

		if pos.x + _size.x > screen_size.x:
			pos.x = screen_size.x - _size.x
		if pos.y + _size.y > screen_size.y:
			pos.y = screen_size.y - _size.y

		tooltip.global_position = pos
