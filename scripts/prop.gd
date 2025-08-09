extends RigidBody3D

@onready var audio_player: AudioStreamPlayer3D = $SFXPlayer
@onready var material_type: String = get_meta("impact_sound_material") if has_meta("impact_sound_material") else "default"
@onready var collider: CollisionShape3D = $CollisionShape3D

@export var weight: float = 1.0
@export var cooldown_time: float = 0.1

var last_contact_times := {}
const SOFT_IMPACT_THRESHOLD := 1.5
const HARD_IMPACT_THRESHOLD := 6.0

# Example: material-to-material lookup
var impact_sounds := {
	"default:default": {
		soft = [
			preload("res://assets/sound/sfx/physics/body/body_medium_impact_soft1.wav"),
			preload("res://assets/sound/sfx/physics/body/body_medium_impact_soft2.wav")
		],
		hard = [
			preload("res://assets/sound/sfx/physics/body/body_medium_impact_hard1.wav"),
			preload("res://assets/sound/sfx/physics/body/body_medium_impact_hard2.wav")
		]
	},
	"wood:default": {
		soft = [
			preload("res://assets/sound/sfx/physics/wood/wood_box_impact_soft1.wav"),
			preload("res://assets/sound/sfx/physics/wood/wood_box_impact_soft2.wav")
		],
		hard = [
			preload("res://assets/sound/sfx/physics/wood/wood_box_impact_hard1.wav"),
			preload("res://assets/sound/sfx/physics/wood/wood_box_impact_hard2.wav")
		]
	}
}

func _ready():
	contact_monitor = true
	max_contacts_reported = 8
	continuous_cd = true

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var time_now = Time.get_ticks_msec() / 1000.0
	var contact_count = state.get_contact_count()
	if contact_count == 0: return

	for i in contact_count:
		var collider = state.get_contact_collider_object(i)
		if not collider: continue

		var key = str(get_instance_id()) + "_" + str(collider.get_instance_id())
		if last_contact_times.has(key) and time_now - last_contact_times[key] < cooldown_time:
			continue

		# Relative velocity along normal
		var normal = state.get_contact_local_normal(i)
		var other_vel = collider.linear_velocity if collider is RigidBody3D else Vector3.ZERO
		var rel_vel = state.get_contact_local_velocity_at_position(i) - other_vel
		var normal_speed = abs(rel_vel.dot(normal))

		if normal_speed > SOFT_IMPACT_THRESHOLD:
			var other_mat = "default"
			if collider.has_meta("impact_sound_material"):
				other_mat = collider.get_meta("impact_sound_material")

			var sound_key = material_type + ":" + other_mat
			var sounds = impact_sounds.get(sound_key, impact_sounds["default:default"])

			var sound_list = sounds.hard if normal_speed > HARD_IMPACT_THRESHOLD else sounds.soft

			var strength = clamp((normal_speed - SOFT_IMPACT_THRESHOLD) / (HARD_IMPACT_THRESHOLD - SOFT_IMPACT_THRESHOLD), 0.0, 1.0)
			play_random_sfx(sound_list, strength)

			last_contact_times[key] = time_now

func play_random_sfx(sound_list: Array, strength: float) -> void:
	if sound_list.is_empty(): return
	var idx = randi() % sound_list.size()
	var eased = pow(strength, 2.5)
	audio_player.pitch_scale = randf_range(0.94, 1.06)
	audio_player.volume_db = lerp(-20.0, 0.0, eased)
	audio_player.play_stream(sound_list[idx])
