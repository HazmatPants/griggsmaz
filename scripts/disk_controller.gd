extends Node

@export var DiskContents := {
	"README.TXT": "meow :3"
}

@export var ReadOnly := false
var DiskID := randi_range(0, 65535)

func duplicate_contents(original: Dictionary) -> Dictionary:
	var copy := {}
	for key in original.keys():
		var value = original[key]
		if typeof(value) == TYPE_DICTIONARY:
			copy[key] = duplicate_contents(value)
		else:
			copy[key] = value
	return copy
