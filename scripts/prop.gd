extends RigidBody3D

@onready var audio_player = $SFXPlayer
@onready var material_type: String = get_meta("impact_sound_material") if has_meta("impact_sound_material") else "default"
@onready var collider = $CollisionShape3D

var impact_cooldown := 0.0

var soft_impact_sounds = {
	"default": [
		preload("res://assets/sound/sfx/physics/body/body_medium_impact_soft1.wav"),
		preload("res://assets/sound/sfx/physics/body/body_medium_impact_soft2.wav"),
		preload("res://assets/sound/sfx/physics/body/body_medium_impact_soft3.wav")
	],
	"wood": [
		preload("res://assets/sound/sfx/physics/wood/wood_box_impact_soft1.wav"),
		preload("res://assets/sound/sfx/physics/wood/wood_box_impact_soft2.wav"),
		preload("res://assets/sound/sfx/physics/wood/wood_box_impact_soft3.wav")
	]
}

var hard_impact_sounds = {
	"default": [
		preload("res://assets/sound/sfx/physics/body/body_medium_impact_hard1.wav"),
		preload("res://assets/sound/sfx/physics/body/body_medium_impact_hard2.wav"),
		preload("res://assets/sound/sfx/physics/body/body_medium_impact_hard3.wav"),
		preload("res://assets/sound/sfx/physics/body/body_medium_impact_hard4.wav"),
		preload("res://assets/sound/sfx/physics/body/body_medium_impact_hard5.wav")
	],
	"wood": [
		preload("res://assets/sound/sfx/physics/wood/wood_box_impact_hard1.wav"),
		preload("res://assets/sound/sfx/physics/wood/wood_box_impact_hard2.wav"),
		preload("res://assets/sound/sfx/physics/wood/wood_box_impact_hard3.wav"),
		preload("res://assets/sound/sfx/physics/wood/wood_box_impact_hard4.wav"),
		preload("res://assets/sound/sfx/physics/wood/wood_box_impact_hard5.wav")
	]
}

const SOFT_IMPACT_THRESHOLD: float = 2.0
const HARD_IMPACT_THRESHOLD: float = 5.0

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 5
	continuous_cd = true

func _physics_process(delta: float) -> void:
	if impact_cooldown > 0.0:
		impact_cooldown -= delta

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() > 0 and impact_cooldown <= 0.0:
		var total_impulse = 0.0
		var contact_count = state.get_contact_count()

		for i in contact_count:
			var contact_impulse = state.get_contact_impulse(i).length()
			total_impulse += contact_impulse

		var average_impulse = total_impulse / max(contact_count, 1)

		if total_impulse > SOFT_IMPACT_THRESHOLD:
			var sound_list: Array
			if total_impulse > HARD_IMPACT_THRESHOLD:
				sound_list = hard_impact_sounds.get(material_type, hard_impact_sounds["default"])
			else:
				sound_list = soft_impact_sounds.get(material_type, soft_impact_sounds["default"])

			var strength = clamp((average_impulse - SOFT_IMPACT_THRESHOLD) / (HARD_IMPACT_THRESHOLD - SOFT_IMPACT_THRESHOLD), 0.0, 1.0)
			play_random_sfx(sound_list, strength)
			impact_cooldown = 0.1

func play_random_sfx(sound_list: Array, strength: float):
	var idx = randi() % sound_list.size()
	var eased = strength * strength
	audio_player.play_stream(sound_list[idx], 0.0, lerp(-18.0, 0.0, eased), randf_range(0.95, 1.05))
