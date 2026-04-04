extends CharacterBody3D

# Player stats
var health: float = 100.0
var armor: float = 0.0
var is_alive: bool = true

# Movement
var walk_speed: float = 4.0
var sprint_speed: float = 6.5
var crouch_speed: float = 2.5
var jump_velocity: float = 4.5
var is_sprinting: bool = false
var is_crouching: bool = false

# Camera
var mouse_sensitivity: float = 0.002
var gyro_sensitivity: float = 0.1

# Gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
@onready var weapon_holder = $Camera3D/WeaponHolder

func _ready():
	print("Player ready!")

func _physics_process(delta):
	if not is_alive:
		return
	apply_gravity(delta)
	handle_movement()
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

func handle_movement():
	var speed = walk_speed
	if is_sprinting:
		speed = sprint_speed
	elif is_crouching:
		speed = crouch_speed

	# Mobile joystick input
	var direction = Vector3.ZERO
	direction = direction.normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)

func take_damage(amount: float, is_headshot: bool = false):
	if not is_alive:
		return
	var final_damage = amount * 2.5 if is_headshot else amount
	if armor > 0:
		var absorbed = min(armor, final_damage * 0.4)
		armor -= absorbed
		final_damage -= absorbed
	health -= final_damage
	if health <= 0:
		die()

func heal(amount: float):
	health = min(100.0, health + amount)

func die():
	is_alive = false
	print("Player died!")

func sprint(active: bool):
	is_sprinting = active

func crouch(active: bool):
	is_crouching = active
