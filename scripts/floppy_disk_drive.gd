extends Node3D

@onready var audio_player = $SFXPlayer
@onready var audio_player2 = $SFXPlayer2

@onready var player = get_tree().get_root().get_node("base/Player")

var Disk: RigidBody3D = null
var DiskData
var DiskController

var canInsert

var sound_insert := preload("res://assets/sound/sfx/disk/floppy/floppy_insert.ogg")
var sound_eject := preload("res://assets/sound/sfx/disk/floppy/floppy_eject.ogg")

var sound_access := [
	preload("res://assets/sound/sfx/disk/floppy/floppy_access1.ogg"),
	preload("res://assets/sound/sfx/disk/floppy/floppy_access2.ogg"),
	preload("res://assets/sound/sfx/disk/floppy/floppy_access3.ogg"),
	preload("res://assets/sound/sfx/disk/floppy/floppy_access4.ogg"),
	preload("res://assets/sound/sfx/disk/floppy/floppy_access5.ogg"),
	preload("res://assets/sound/sfx/disk/floppy/floppy_access6.ogg")
]

signal DiskInserted
signal DiskEjected

func play_access_sound():
	audio_player2.play_stream(sound_access[randi_range(0, sound_access.size() - 1)])

func eject_disk():
	if Disk:
		Disk.freeze = false
		Disk.collider.disabled = false
		Disk.gravity_scale = 1.0
		Disk.apply_central_impulse(Vector3(1.0, 0.3, 0.0))

		audio_player.play_stream(sound_eject)
		print("Disk ejected")
		DiskEjected.emit()

		Disk = null
		DiskData = null

func insert_disk(disk: Node3D):
	audio_player.play_stream(sound_insert)

	var diskID = disk.DiskID
	var disk_contents = disk.DiskContents

	var data = {
		"id": diskID,
		"contents": disk_contents
	}

	print("Disk inserted with data: ", data)
	DiskInserted.emit()

	play_access_sound()

	return data

func interact():
	if Disk:
		eject_disk()
	else:
		if player.object_in_hand != null:
			if player.object_in_hand.name == "FloppyDisk":
				Disk = player.object_in_hand
				player.object_in_hand = null
				DiskController = Disk.get_node("FloppyDisk")
				DiskData = insert_disk(DiskController)
				Disk.freeze = true
				Disk.collider.disabled = true
				Disk.global_position = global_position + Vector3(0.07, 0.0, 0.0)
				Disk.rotation = rotation + Vector3(0.0, deg_to_rad(270.0), deg_to_rad(90.0))
