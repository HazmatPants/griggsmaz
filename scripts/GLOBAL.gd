extends Node

var DAYS: int = 0
# how many days have passed

var TIME: float = 360 # in-game minutes
# 1 in-game minute is 3 real seconds
# 1 in-game hour is 3 real minutes
# 1 in-game day is 72 real minutes
# 1 in-game day is 1440 in-game minutes

var CanPause: bool = true

var settings: Dictionary = {
	"video": {
		"bloom": true,
		"ssr": true
	}
}

func load_sounds_from_dir(path: String) -> Array:
	var sounds := []
	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".ogg"):
				var stream := load(path + "/" + file_name)
				if stream is AudioStream:
					sounds.append(stream)
			file_name = dir.get_next()
		dir.list_dir_end()
		return sounds
	return []

func _process(delta: float) -> void:
	TIME += delta / 3
	if TIME > 1440:
		TIME = 0
		DAYS += 1

func get_time_string() -> String:
	var hours = TIME / 60
	var minutes = int(TIME) % 60
	var time_string = "%02d:%02d" % [hours, minutes]
	return time_string
