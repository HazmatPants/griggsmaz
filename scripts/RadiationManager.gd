extends Node

var sources: Array = []

func register_source(s):
	if s not in sources:
		sources.append(s)

func unregister_source(s):
	sources.erase(s)

# Calculate the radiation flux at a position
# pos: Vector3; optionally supply a "shielding" factor (material attenuation).
func flux_at(pos: Vector3, delta: float) -> float:
	var total: float = 0.0
	for s in sources:
		if not is_instance_valid(s): continue
		var strength = s.current_strength(delta)
		if strength <= 0.0: continue
		var d = pos.distance_to(s.global_transform.origin)
		if d > s.effective_range: continue
		# inverse-square falloff with softcap
		var falloff = 1.0 / max(d * d, 0.1)
		# base contribution
		total += strength * falloff
	return total
