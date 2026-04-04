extends CharacterBody3D

enum WraithTier {GRUNT, ELITE, COMMANDER, BOSS}
enum AIState {PATROL, CHASE, ATTACK, DEAD}

@export var tier: WraithTier = WraithTier.GRUNT
@export var sight_range: float = 25.0
@export var hearing_range: float = 15.0
@export var attack_range: float = 5.0

var health: float = 100.0
var state: AIState = AIState.PATROL
var target: Node3D = null
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Damage per tier
var damage_map = {
	WraithTier.GRUNT: 15.0,
	WraithTier.ELITE: 25.0,
	WraithTier.COMMANDER: 35.0,
	WraithTier.BOSS: 50.0
}

# Speed per tier
var speed_map = {
	WraithTier.GRUNT: 3.0,
	WraithTier.ELITE: 4.5,
	WraithTier.COMMANDER: 4.0,
	WraithTier.BOSS: 2.5
}

func _ready():
	health = get_max_health()
	print("Wraith spawned: ", WraithTier.keys()[tier])

func get_max_health() -> float:
	match tier:
		WraithTier.GRUNT: return 100.0
		WraithTier.ELITE: return 200.0
		WraithTier.COMMANDER: return 350.0
		WraithTier.BOSS: return 1000.0
	return 100.0

func _physics_process(delta):
	if state == AIState.DEAD:
		return
	apply_gravity(delta)
	match state:
		AIState.PATROL: patrol()
		AIState.CHASE: chase_target(delta)
		AIState.ATTACK: attack_target()
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

func patrol():
	if target and get_distance_to_target() < sight_range:
		state = AIState.CHASE

func chase_target(delta):
	if not target:
		state = AIState.PATROL
		return
	if get_distance_to_target() < attack_range:
		state = AIState.ATTACK
		return
	var direction = (target.global_position - global_position).normalized()
	velocity.x = direction.x * speed_map[tier]
	velocity.z = direction.z * speed_map[tier]

func attack_target():
	if not target:
		state = AIState.PATROL
		return
	if get_distance_to_target() > attack_range:
		state = AIState.CHASE
		return
	if target.has_method("take_damage"):
		target.take_damage(damage_map[tier])

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		die()

func die():
	state = AIState.DEAD
	print("Wraith eliminated!")
	queue_free()

func get_distance_to_target() -> float:
	if not target:
		return INF
	return global_position.distance_to(target.global_position)

func set_target(new_target: Node3D):
	target = new_target
	state = AIState.CHASE
