extends Node3D

@export var max_click_rate: float = 10.0 # max clicks per second at high radiation
@export var min_click_interval: float = 0.001 # minimum time between clicks (avoid crazy speed)
@export var detection_range: float = 10.0 # meters radius to detect radiation

var time_since_last_click: float = 0.0
var click_interval: float = 1.0 # seconds between clicks

var audio_player: SteamAudioPlayer

func _ready():
	audio_player = $SFXPlayer
	time_since_last_click = 0.0

func _process(delta):
	time_since_last_click += delta

	# get current dose rate from RadiationManager at this object's position
	var raw_flux = RadiationManager.flux_at(global_transform.origin, delta)
	if has_node("RadiationLabel"):
		$RadiationLabel.text = "Radiation: %.2f" % raw_flux

	# optionally clamp based on detection_range, ignore if outside
	if raw_flux <= 0.01:
		# very low radiation: no clicks
		return

	# map radiation level to click rate (clicks per second)
	# Simple linear scaling capped at max_click_rate
	var rate = clamp(raw_flux, 0.0, max_click_rate)
	click_interval = max(min_click_interval, 1.0 / rate)

	if time_since_last_click >= click_interval:
		audio_player.play()
		time_since_last_click = 0.0
