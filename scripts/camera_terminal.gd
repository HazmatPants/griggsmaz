extends StaticBody3D

@onready var cameras := {
	"cam1": $SubViewport/cam1,
	"cam2": $SubViewport/cam2
}

var active_camera_name: String = "cam1"
@onready var active_camera: Camera3D = cameras[active_camera_name]
@onready var viewport := $SubViewport
@onready var playerGUI = GLOBAL.PlayerGUI
@onready var base =GLOBAL.PlayerScene

var blackscreen: StandardMaterial3D
var defaultscreen: StandardMaterial3D

func _ready() -> void:
	$Screen.get_active_material(0).albedo_texture.viewport_path = NodePath("Level/Console/CameraTerminal/SubViewport")
	refresh_screen(5)
	defaultscreen = $Screen.mesh.material

	blackscreen = StandardMaterial3D.new()
	blackscreen.albedo_color = Color(0, 0, 0, 1)
	blackscreen.roughness = defaultscreen.roughness
	
	base.PowerOff.connect(_PowerOff)
	base.PowerOn.connect(_PowerOn)

func _PowerOff():
	$Screen.mesh.material = blackscreen

func _PowerOn():
	$Screen.mesh.material = defaultscreen

func switch_camera(to: Camera3D):
	active_camera_name = to.name
	active_camera = to
	for i in cameras.values():
		if i == active_camera:
			i.current = true
		else:
			i.current = false

func cam_snapshot():
	var image = get_viewport().get_texture().get_image()
	var time = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var dir = "user://camSnaps"
	var path = "%s/%s_snapshot_%s.png" % [dir, active_camera_name, time]
	
	visible = false

	# Make sure the directory exists
	var dir_access = DirAccess.open("user://")
	if not dir_access.dir_exists("camSnaps"):
		dir_access.make_dir("camSnaps")

	var error = image.save_png(path)
	if error == OK:
		print("Snapshot saved to: ", ProjectSettings.globalize_path(path))
		playerGUI.show_popup("Snapshot saved to: " + ProjectSettings.globalize_path(path), playerGUI.camera_sound)
	else:
		print("Snapshot failed to save.")
		playerGUI.show_popup("Snapshot failed to save.", playerGUI.popup_sound)
	
	visible = true

func refresh_screen(fps: float):
	await get_tree().create_timer(1 / fps).timeout
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	refresh_screen(fps)
