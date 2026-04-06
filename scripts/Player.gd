extends CharacterBody3D

# =========================
# PLAYER STATS
# =========================
var health: float = 100.0
var armor: float = 0.0
var is_alive: bool = true

# =========================
# MOVEMENT
# =========================
var walk_speed: float = 4.0
var sprint_speed: float = 6.5
var crouch_speed: float = 2.5
var jump_velocity: float = 4.5

var is_sprinting: bool = false
var is_crouching: bool = false

# =========================
# CAMERA
# =========================
var mouse_sensitivity: float = 0.003
var rotation_x: float = 0.0

# =========================
# GRAVITY
# =========================
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# =========================
# NODE REFERENCES
# =========================
@onready var head = $Head
@onready var camera = $Head/Camera3D

# =========================
# READY
# =========================
func _ready():
	print("Player ready!")

# =========================
# INPUT (CAMERA CONTROL)
# =========================
func _input(event):
	if event is InputEventScreenDrag:
		# Rotate player (left/right)
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Rotate head (up/down)
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, deg_to_rad(-80), deg_to_rad(80))

		head.rotation.x = rotation_x

# =========================
# PHYSICS LOOP
# =========================
func _physics_process(delta):
	if not is_alive:
		return

	apply_gravity(delta)
	handle_movement()
	move_and_slide()

# =========================
# GRAVITY
# =========================
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

# =========================
# MOVEMENT
# =========================
func handle_movement():
	var speed = walk_speed

	if is_sprinting:
		speed = sprint_speed
	elif is_crouching:
		speed = crouch_speed

	var input_dir = Vector2.ZERO

	# TEMP controls (keyboard fallback)
	if Input.is_action_pressed("ui_up"):
		input_dir.y += 1
	if Input.is_action_pressed("ui_down"):
		input_dir.y -= 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	# Convert input into world direction based on player rotation
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

# =========================
# DAMAGE SYSTEM
# =========================
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

# =========================
# HEAL
# =========================
func heal(amount: float):
	health = min(100.0, health + amount)

# =========================
# DEATH
# =========================
func die():
	is_alive = false
	print("Player died!")

# =========================
# STATES
# =========================
func sprint(active: bool):
	is_sprinting = active

func crouch(active: bool):
	is_crouching = active
