extends SubViewport

@onready var time_label := $Control/Label
@onready var am_pm_label := $Control/AM_PM_Label

var flash_colon := true
var timer := 0.0

enum ClockType { TWENTY_FOUR_HOUR, TWELVE_HOUR }

@export_enum("24 Hour", "12 Hour")
var clock_type: int = ClockType.TWENTY_FOUR_HOUR

func _ready():
	if clock_type == ClockType.TWENTY_FOUR_HOUR:
		am_pm_label.text = ""

func _process(delta: float) -> void:
	timer += delta
	if timer >= 0.5:
		timer = 0
		flash_colon = !flash_colon
		update_time()

func update_time():
	var time: String
	if clock_type == ClockType.TWELVE_HOUR:
		time = get_12_hour_time()
	else:
		time = GLOBAL.get_time_string()
	if flash_colon:
		time_label.text = time
	else:
		time_label.text = time.replace(":", " ")

func get_12_hour_time() -> String:
	var time_24 := GLOBAL.get_time_string()
	var parts := time_24.split(":")
	if parts.size() < 2:
		return time_24

	var hour := int(parts[0])
	var minute := parts[1]

	var am_pm := "AM"
	if hour >= 12:
		am_pm = "PM"
	if hour > 12:
		hour -= 12
	elif hour == 0:
		hour = 12
	
	am_pm_label.text = am_pm

	return "%02d:%s" % [hour, minute]
