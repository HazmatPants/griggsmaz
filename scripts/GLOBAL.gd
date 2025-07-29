extends Node

var CanPause := true

var settings := {
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
