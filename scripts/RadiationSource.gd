extends Node3D

@export var strength: float = 100.0   # arbitrary units (source intensity)
@export var effective_range: float = 20.0 # meters
@export var half_life_seconds: float = 0.0 # >0 if the source decays over time

func _ready():
	RadiationManager.register_source(self)

func _exit_tree():
	RadiationManager.unregister_source(self)

# did someone say half-life?
# *Hazardous Environments starts playing*
func current_strength(delta: float) -> float:
	# decays by exponential half-life if set
	if half_life_seconds > 0.0:
		var lambda = log(2.0) / half_life_seconds
		# this computes remaining fraction over the last frame
		# but we'll just reduce the strength property over time
		strength = strength * exp(-lambda * delta)
	return strength
