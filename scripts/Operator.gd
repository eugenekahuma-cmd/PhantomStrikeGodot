extends Node

enum OperatorRole {ASSAULT, RECON, SUPPORT, TANK, MEDIC, STEALTH, TECH, SNIPER}

@export var operator_name: String = "Viper"
@export var role: OperatorRole = OperatorRole.ASSAULT
@export var cooldown_duration: float = 30.0

var cooldown_remaining: float = 0.0
var is_on_cooldown: bool = false
var owner_player: Node = null

signal ability_activated(operator_name)
signal cooldown_finished(operator_name)

func _ready():
	print("Operator ready: ", operator_name)

func _process(delta):
	if is_on_cooldown:
		cooldown_remaining -= delta
		if cooldown_remaining <= 0:
			cooldown_remaining = 0.0
			is_on_cooldown = false
			emit_signal("cooldown_finished", operator_name)

func activate() -> bool:
	if is_on_cooldown:
		print("Ability on cooldown: ", cooldown_remaining)
		return false
	on_activate()
	start_cooldown()
	emit_signal("ability_activated", operator_name)
	return true

func on_activate():
	print(operator_name, " ability activated!")
	match operator_name:
		"Viper":
			spawn_emp_grenade()
		"Ghost":
			activate_cloak()
		"Flare":
			activate_stim()
		"Shade":
			deploy_drone()
		"Nova":
			deploy_turret()

func spawn_emp_grenade():
	print("EMP Grenade thrown! Disabling enemy gadgets nearby!")

func activate_cloak():
	print("Ghost cloaked for 4 seconds!")
	if owner_player:
		owner_player.modulate = Color(1, 1, 1, 0.15)
		await get_tree().create_timer(4.0).timeout
		owner_player.modulate = Color(1, 1, 1, 1.0)

func activate_stim():
	print("Combat stim activated! +40 HP!")
	if owner_player and owner_player.has_method("heal"):
		owner_player.heal(40.0)

func deploy_drone():
	print("Drone deployed!")

func deploy_turret():
	print("Sentry turret deployed!")

func start_cooldown():
	is_on_cooldown = true
	cooldown_remaining = cooldown_duration

func get_cooldown_percent() -> float:
	if not is_on_cooldown:
		return 1.0
	return 1.0 - (cooldown_remaining / cooldown_duration)

func initialize(player: Node):
	owner_player = player
