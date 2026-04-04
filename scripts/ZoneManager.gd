extends Node3D

enum ZonePhase {WAITING, PHASE1, PHASE2, PHASE3, PHASE4, FINAL}

@export var zone_damage: float = 5.0

var current_phase: ZonePhase = ZonePhase.WAITING
var zone_center: Vector3 = Vector3.ZERO
var zone_radius: float = 300.0
var next_radius: float = 200.0
var phase_timer: float = 0.0

var phase_times = [0, 240, 180, 150, 120, 90]
var phase_radii = [300.0, 200.0, 120.0, 60.0, 20.0, 8.0]

signal phase_changed(new_phase)
signal player_outside_zone(player)

func _ready():
	print("Zone Manager ready!")

func start_zone():
	current_phase = ZonePhase.PHASE1
	zone_radius = phase_radii[0]
	next_radius = phase_radii[1]
	emit_signal("phase_changed", current_phase)

func _process(delta):
	if current_phase == ZonePhase.WAITING:
		return
	phase_timer += delta
	var current_phase_time = phase_times[current_phase]
	if phase_timer >= current_phase_time:
		phase_timer = 0.0
		advance_phase()

func advance_phase():
	if current_phase == ZonePhase.FINAL:
		return
	current_phase = current_phase + 1 as ZonePhase
	zone_radius = phase_radii[current_phase]
	if current_phase < ZonePhase.FINAL:
		next_radius = phase_radii[current_phase + 1]
	emit_signal("phase_changed", current_phase)
	print("Zone phase: ", ZonePhase.keys()[current_phase])

func is_outside_zone(position: Vector3) -> bool:
	return position.distance_to(zone_center) > zone_radius

func get_zone_progress() -> float:
	if current_phase == ZonePhase.WAITING:
		return 0.0
	var current_phase_time = phase_times[current_phase]
	return phase_timer / current_phase_time
