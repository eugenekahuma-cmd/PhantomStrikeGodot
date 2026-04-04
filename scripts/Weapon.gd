extends Node3D

enum FireMode {SINGLE, BURST, AUTO}

# Weapon stats
@export var weapon_name: String = "Rifle"
@export var damage: float = 35.0
@export var fire_rate: float = 0.1
@export var mag_size: int = 30
@export var reload_time: float = 2.4
@export var range: float = 100.0
@export var headshot_multiplier: float = 2.5
@export var fire_mode: FireMode = FireMode.AUTO

# State
var current_ammo: int = 30
var reserve_ammo: int = 90
var is_reloading: bool = false
var is_firing: bool = false
var spread: float = 0.0

@onready var raycast = $RayCast3D
@onready var muzzle = $MuzzlePoint

func _ready():
	current_ammo = mag_size

func start_fire():
	if is_reloading or current_ammo <= 0:
		reload()
		return
	is_firing = true
	fire()

func stop_fire():
	is_firing = false
	spread = max(0.0, spread - 0.5)

func fire():
	if current_ammo <= 0:
		reload()
		return
	current_ammo -= 1
	spread = min(spread + 0.15, 3.0)
	perform_raycast()
	if fire_mode == FireMode.AUTO and is_firing:
		await get_tree().create_timer(fire_rate).timeout
		if is_firing:
			fire()

func perform_raycast():
	if raycast.is_colliding():
		var hit = raycast.get_collider()
		if hit.has_method("take_damage"):
			var is_headshot = raycast.get_collision_point().y > hit.global_position.y + 1.5
			hit.take_damage(damage, is_headshot)

func reload():
	if is_reloading or reserve_ammo <= 0:
		return
	if current_ammo == mag_size:
		return
	is_reloading = true
	await get_tree().create_timer(reload_time).timeout
	var needed = mag_size - current_ammo
	var added = min(needed, reserve_ammo)
	current_ammo += added
	reserve_ammo -= added
	is_reloading = false

func get_ammo_display() -> String:
	return str(current_ammo) + " / " + str(reserve_ammo)
