extends CharacterBody3D

@export var move_speed := 4.0
@export var sprint_speed := 7.0
@export var acceleration := 8.0
@export var decceleration := 8.0
@export var mouse_sensitivity := 0.004
@export var jump_velocity := 4.5
@export var gravity := Vector3.DOWN * 9.8
var mouse_look_enabled := true


var look_rotation: Vector2 = Vector2.ZERO

@onready var camera = $Camera3D
@onready var interactray = $Camera3D/InteractRay
@onready var footstepRay = $FootstepRay
@onready var grab_point = $Camera3D/GrabPoint
var held_object: RigidBody3D = null

# for playing spatialized sounds
@onready var audio_player = $SFXPlayer

# for playing non-spatialized sounds
@onready var local_audio_player = $LocalSFXPlayer

@onready var interactText = $"../PlayerGUI/InteractLabel"
@onready var crosshair = $"../PlayerGUI/Crosshair"
var image_crosshair = preload("res://assets/textures/ui/crosshair2.png")
var image_crosshair_interact = preload("res://assets/textures/ui/crosshair_interact.png")
var image_crosshair_hand = preload("res://assets/textures/ui/crosshair_hand.png")
var bobbing_time := 0.0
@export var bobbing_speed := 14.0
@export var bobbing_amount := 0.05

var last_bob_value := 0.0

var footstep_cooldown := 0.0
@export var footstep_interval := 0.2

@export var sprint_bobbing_speed := 18.0
@export var sprint_bobbing_amount := 0.08
@export var sprint_footstep_interval := 0.15

@export var ambient_sway_speed := 0.5
@export var ambient_pitch_amount := 2.0
@export var ambient_roll_amount := 1.0

@export var strafe_roll_amount := 2.0
@export var strafe_roll_speed := 8.0

var viewpunch_rotation := Vector3.ZERO
var viewpunch_velocity := Vector3.ZERO

@export var viewpunch_damping := 6.0
@export var jump_viewpunch := Vector3(60.0, 0, 0)
@export var land_viewpunch := Vector3(-40.0, 0, 0)
@export var step_viewpunch := Vector3(-10.0, 0, 0)

var was_on_floor := false

@export var step_kick := 12.0
var step_side := true

var current_strafe_roll := 0.0

var ambient_time := 0.0

var base_camera_position := Vector3.ZERO

var was_moving := false
var is_moving := false
var stop_timer := 0.0

var rotating: bool = false
var last_mouse_pos := Vector2.ZERO
@export var rotation_sensitivity := 0.01

var step_sounds = {
	"default": [
		preload("res://assets/sound/sfx/footsteps/default/default_step1.wav"),
		preload("res://assets/sound/sfx/footsteps/default/default_step2.wav"),
		preload("res://assets/sound/sfx/footsteps/default/default_step3.wav"),
		preload("res://assets/sound/sfx/footsteps/default/default_step4.wav")
	],
	"plastic": [
		preload("res://assets/sound/sfx/footsteps/plastic/plastic_step1.wav"),
		preload("res://assets/sound/sfx/footsteps/plastic/plastic_step2.wav"),
		preload("res://assets/sound/sfx/footsteps/plastic/plastic_step3.wav"),
		preload("res://assets/sound/sfx/footsteps/plastic/plastic_step4.wav")
	],
	"metal": [
		preload("res://assets/sound/sfx/footsteps/metal/metal_step1.ogg"),
		preload("res://assets/sound/sfx/footsteps/metal/metal_step2.ogg"),
		preload("res://assets/sound/sfx/footsteps/metal/metal_step3.ogg"),
		preload("res://assets/sound/sfx/footsteps/metal/metal_step4.ogg")
	],
	"concrete": [
		preload("res://assets/sound/sfx/footsteps/concrete/concrete_step1.ogg"),
		preload("res://assets/sound/sfx/footsteps/concrete/concrete_step2.ogg"),
		preload("res://assets/sound/sfx/footsteps/concrete/concrete_step3.ogg"),
		preload("res://assets/sound/sfx/footsteps/concrete/concrete_step4.ogg")
	],
	"squeakywood": [
		preload("res://assets/sound/sfx/footsteps/squeakywood/squeakywood_walk1.ogg"),
		preload("res://assets/sound/sfx/footsteps/squeakywood/squeakywood_walk2.ogg"),
		preload("res://assets/sound/sfx/footsteps/squeakywood/squeakywood_walk3.ogg"),
		preload("res://assets/sound/sfx/footsteps/squeakywood/squeakywood_walk4.ogg")
	]
}

var impact_sounds = {
	"default": [
		preload("res://assets/sound/sfx/footsteps/default/default_step1.wav"),
		preload("res://assets/sound/sfx/footsteps/default/default_step2.wav"),
		preload("res://assets/sound/sfx/footsteps/default/default_step3.wav"),
		preload("res://assets/sound/sfx/footsteps/default/default_step4.wav")
	],
	"plastic": [
		preload("res://assets/sound/sfx/footsteps/plastic/plastic_step1.wav"),
		preload("res://assets/sound/sfx/footsteps/plastic/plastic_step2.wav"),
		preload("res://assets/sound/sfx/footsteps/plastic/plastic_step3.wav"),
		preload("res://assets/sound/sfx/footsteps/plastic/plastic_step4.wav")
	],
	"metal": [
		preload("res://assets/sound/sfx/footsteps/metal/metal_land1.ogg"),
		preload("res://assets/sound/sfx/footsteps/metal/metal_land2.ogg")
	],
	"concrete": [
		preload("res://assets/sound/sfx/footsteps/concrete/concrete_land1.ogg"),
		preload("res://assets/sound/sfx/footsteps/concrete/concrete_land2.ogg")
	]
}

var wander_sounds = {
	"default": [
		preload("res://assets/sound/sfx/footsteps/default/default_wander1.ogg"),
		preload("res://assets/sound/sfx/footsteps/default/default_wander2.ogg"),
		preload("res://assets/sound/sfx/footsteps/default/default_wander3.ogg"),
		preload("res://assets/sound/sfx/footsteps/default/default_wander4.ogg")
	],
	"plastic": [
		preload("res://assets/sound/sfx/footsteps/plastic/plastic_step1.wav"),
		preload("res://assets/sound/sfx/footsteps/plastic/plastic_step2.wav"),
		preload("res://assets/sound/sfx/footsteps/plastic/plastic_step3.wav"),
		preload("res://assets/sound/sfx/footsteps/plastic/plastic_step4.wav")
	],
	"metal": [
		preload("res://assets/sound/sfx/footsteps/metal/metal_wander1.ogg"),
		preload("res://assets/sound/sfx/footsteps/metal/metal_wander2.ogg"),
		preload("res://assets/sound/sfx/footsteps/metal/metal_wander3.ogg"),
		preload("res://assets/sound/sfx/footsteps/metal/metal_wander4.ogg")
	],
	"concrete": [
		preload("res://assets/sound/sfx/footsteps/concrete/concrete_wander1.ogg"),
		preload("res://assets/sound/sfx/footsteps/concrete/concrete_wander2.ogg"),
		preload("res://assets/sound/sfx/footsteps/concrete/concrete_wander3.ogg"),
		preload("res://assets/sound/sfx/footsteps/concrete/concrete_wander4.ogg")
	],
	"squeakywood": [
		preload("res://assets/sound/sfx/footsteps/squeakywood/squeakywood_wander1.ogg"),
		preload("res://assets/sound/sfx/footsteps/squeakywood/squeakywood_wander2.ogg"),
		preload("res://assets/sound/sfx/footsteps/squeakywood/squeakywood_wander3.ogg"),
		preload("res://assets/sound/sfx/footsteps/squeakywood/squeakywood_wander4.ogg")
	]
}

var deny_sound = preload("res://assets/sound/sfx/ui/suit_denydevice.wav")

func play_random_sfx(sound_list):
	var idx = randi() % sound_list.size()
	audio_player.play_stream(sound_list[idx], 0.0, 0.0, randf_range(0.95, 1.05))

func footstep_sound(type: String="step"):
	if footstepRay.is_colliding():
		var collider = footstepRay.get_collider()
		var material = "default"
		var sound_list

		if collider.has_meta("material_type"):
			material = collider.get_meta("material_type")
		
		if type == "impact":
			sound_list = impact_sounds.get(material, step_sounds.get(material, impact_sounds["default"]))
		elif type == "step":
			sound_list = step_sounds.get(material, step_sounds["default"])
		elif type == "wander":
			sound_list = wander_sounds.get(material, wander_sounds["default"])

		play_random_sfx(sound_list)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	base_camera_position = camera.position

func _unhandled_input(event):
	if event is InputEventMouseMotion and mouse_look_enabled:
		look_rotation.x -= event.relative.x * mouse_sensitivity
		look_rotation.y -= event.relative.y * mouse_sensitivity
		look_rotation.y = clamp(look_rotation.y, -1.5, 1.5)
		rotation.y = look_rotation.x
		camera.rotation.x = look_rotation.y

func _physics_process(delta):
	var input_dir = Vector3.ZERO
	var forward = -transform.basis.z.normalized()
	var right = transform.basis.x.normalized()

	if Input.is_action_pressed("move_forward"):
		input_dir += forward
	if Input.is_action_pressed("move_backward"):
		input_dir -= forward
	if Input.is_action_pressed("move_right"):
		input_dir += right
	if Input.is_action_pressed("move_left"):
		input_dir -= right

	var target_roll = 0.0

	if is_on_floor():
		if Input.is_action_pressed("move_left"):
			target_roll = deg_to_rad(strafe_roll_amount)
		elif Input.is_action_pressed("move_right"):
			target_roll = -deg_to_rad(strafe_roll_amount)

	current_strafe_roll = lerp(current_strafe_roll, target_roll, delta * strafe_roll_speed)

	input_dir = input_dir.normalized()
	var sprinting = Input.is_action_pressed("sprint") and is_on_floor()
	
	var speed = sprint_speed if sprinting else move_speed
	var desired_velocity = input_dir * speed
	# Separate XZ velocity
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)

	# Pick accel/decel based on input and limit it when in air
	var accel
	if input_dir.length() > 0:
		if is_on_floor():
			accel = acceleration
		else:
			accel = acceleration * 0.05
	else:
		if is_on_floor():
			accel = decceleration
		else:
			accel = decceleration * 0.05

	horizontal_velocity = horizontal_velocity.lerp(desired_velocity, accel * delta)

	# Apply smoothed XZ back to velocity
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	
	var current_bobbing_speed = sprint_bobbing_speed if sprinting else bobbing_speed
	var current_bobbing_amount = sprint_bobbing_amount if sprinting else bobbing_amount
	var current_footstep_interval = sprint_footstep_interval if sprinting else footstep_interval



	if not is_on_floor():
		velocity += gravity * delta
	else:
		velocity.y = 0
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
			viewpunch_velocity += jump_viewpunch
			footstep_sound("impact")

	move_and_slide()

	var vel = get_real_velocity()
	is_moving = vel.length() > 0.3
	
	if not is_moving:
		current_strafe_roll = lerp(current_strafe_roll, target_roll, delta * 4.0)

	if was_moving and not is_moving:
		stop_timer = 0.0

	if not is_moving and not was_moving:
		stop_timer += delta
		if stop_timer > 0.05:
			footstep_sound("wander")
			viewpunch_velocity += step_viewpunch / 2
			stop_timer = -999  # prevent multiple plays

	was_moving = is_moving

	# Landing detection
	if not was_on_floor and is_on_floor():
		viewpunch_velocity += land_viewpunch
		footstep_sound("impact")

	viewpunch_rotation += viewpunch_velocity * delta
	viewpunch_velocity = lerp(viewpunch_velocity, Vector3.ZERO, delta * viewpunch_damping)
	viewpunch_rotation = lerp(viewpunch_rotation, Vector3.ZERO, delta * viewpunch_damping)

	was_on_floor = is_on_floor()

	if is_on_floor() and input_dir.length() > 0:
		bobbing_time += delta * current_bobbing_speed
		var bob_offset = sin(bobbing_time) * current_bobbing_amount
		camera.position.y = base_camera_position.y + bob_offset
	else:
		camera.position.y = lerp(camera.position.y, base_camera_position.y, delta * 10.0)
		bobbing_time = 0.0

	if is_on_floor() and input_dir.length() > 0:
		var bob_value = sin(bobbing_time)

		if bob_value < 0.0 and last_bob_value >= 0.0 and footstep_cooldown <= 0.0:
			footstep_sound("step")
			viewpunch_velocity += step_viewpunch
			footstep_cooldown = current_footstep_interval
			step_side = not step_side
			viewpunch_velocity += Vector3(0, 0, step_kick) if step_side else Vector3(0, 0, -step_kick)

		last_bob_value = bob_value
		footstep_cooldown -= delta
	else:
		last_bob_value = 0.0
		footstep_cooldown = 0.0

	ambient_time += delta * ambient_sway_speed

	# Ambient sway rotation
	var sway_pitch = deg_to_rad(sin(ambient_time) * ambient_pitch_amount)
	var ambient_roll = deg_to_rad(cos(ambient_time * 0.5) * ambient_roll_amount)

	var total_pitch = look_rotation.y + sway_pitch + deg_to_rad(viewpunch_rotation.x)
	var total_roll = ambient_roll + current_strafe_roll + deg_to_rad(viewpunch_rotation.z)

	var camera_rot = Vector3.ZERO
	camera_rot.x = total_pitch
	camera_rot.y = deg_to_rad(viewpunch_rotation.y)
	camera_rot.z = total_roll
	camera.rotation = camera_rot

	if held_object:
		move_held_object_physical(delta)

func move_held_object_physical(delta):
	var target_pos = grab_point.global_transform.origin
	var current_pos = held_object.global_transform.origin
	var direction = target_pos - current_pos

	var distance = direction.length()
	var direction_normalized = direction.normalized()
	
	var spring_strength = 50.0
	var damping = 8.0
	
	var relative_velocity = held_object.linear_velocity
	var force = direction_normalized * (distance * spring_strength) - relative_velocity * damping
	
	held_object.angular_velocity = held_object.angular_velocity.lerp(Vector3.ZERO, 0.1)
	held_object.apply_central_force(force)
	
	var is_rotating_object := Input.is_action_pressed("rmb")
	mouse_look_enabled = not is_rotating_object
	
	if is_rotating_object and held_object:
		var mouse_delta = Input.get_last_mouse_velocity()

		# Sensitivity multiplier — tweak to your liking
		var sensitivity = 0.00005

		# Apply rotation around Y (horizontal) and X (vertical)
		var rot_x = mouse_delta.y * sensitivity
		var rot_y = -mouse_delta.x * sensitivity  # negative to make dragging feel natural

		# Apply local rotation
		held_object.rotate_object_local(Vector3.UP, rot_y)
		held_object.rotate_object_local(Vector3.RIGHT, rot_x)



func throw_object():
	if held_object:
		var throw_strength = 500.0
		var direction = camera.global_transform.basis.z * -1.0
		held_object.gravity_scale = 1.0
		held_object.apply_central_force(direction * throw_strength)
		held_object = null

func try_grab():
	if interactray.is_colliding():
		var collider = interactray.get_collider()
		if collider.has_meta("grabbable") and collider.get_meta("grabbable"):
			if not collider == footstepRay.get_collider():
				print("Grabbed: ", collider)
				held_object = collider
				held_object.gravity_scale = 0.0
				held_object.linear_velocity = Vector3.ZERO
				held_object.angular_velocity = Vector3.ZERO
			else:
				local_audio_player.stream = deny_sound
				local_audio_player.play()

func drop_object():
	if held_object:
		print("Dropped: ", held_object)
		held_object.gravity_scale = 1.0
		held_object = null

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("lmb"):
		if held_object:
			throw_object()
	if Input.is_action_just_released("interact"):
		if held_object:
			drop_object()
			return
	if Input.is_action_just_pressed("interact"):
		if interactray.is_colliding():
			if not held_object:
				try_grab()

	if interactray.is_colliding():
		var collider = interactray.get_collider()
		interactText.visible = true
		crosshair.texture = image_crosshair_interact
		if collider.has_meta("grabbable"):
			if collider.get_meta("grabbable"):
				crosshair.texture = image_crosshair_hand
				if held_object:
					interactText.text = "Drop [E]"
				else:
					interactText.text = "Grab [E]"
		else:
			interactText.text = "Interact [E]"
		if Input.is_action_just_pressed("interact"):
			print("Interacted with: ", collider.name)
			if collider.name == "LockButton":
				collider.get_parent().toggle_lock()
			elif collider.name == "ToggleButton":
				collider.get_parent().interact()
	else:
		interactText.visible = false
		crosshair.texture = image_crosshair
	if held_object:
		crosshair.texture = image_crosshair_hand
		interactText.text = "Drop [E]"
		interactText.visible = true
