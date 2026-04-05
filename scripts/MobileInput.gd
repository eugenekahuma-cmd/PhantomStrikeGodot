extends Node

# Touch input manager for mobile
signal left_joystick_moved(direction)
signal right_joystick_moved(direction)
signal fire_pressed
signal fire_released
signal jump_pressed
signal reload_pressed
signal crouch_pressed
signal ads_pressed
signal operator_pressed

# Joystick settings
var left_joystick_active: bool = false
var right_joystick_active: bool = false
var left_touch_index: int = -1
var right_touch_index: int = -1
var left_origin: Vector2 = Vector2.ZERO
var right_origin: Vector2 = Vector2.ZERO
var joystick_radius: float = 100.0

# Gyroscope
var gyro_enabled: bool = false
var gyro_sensitivity: float = 0.1

func _ready():
	print("Mobile Input ready!")

func _input(event):
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)

func handle_touch(event: InputEventScreenTouch):
	if event.pressed:
		# Left side of screen = movement joystick
		if event.position.x < get_viewport().size.x / 2:
			left_joystick_active = true
			left_touch_index = event.index
			left_origin = event.position
		else:
			right_joystick_active = true
			right_touch_index = event.index
			right_origin = event.position
	else:
		if event.index == left_touch_index:
			left_joystick_active = false
			left_touch_index = -1
			emit_signal("left_joystick_moved", Vector2.ZERO)
		elif event.index == right_touch_index:
			right_joystick_active = false
			right_touch_index = -1
			emit_signal("right_joystick_moved", Vector2.ZERO)

func handle_drag(event: InputEventScreenDrag):
	if event.index == left_touch_index:
		var offset = event.position - left_origin
		if offset.length() > joystick_radius:
			offset = offset.normalized() * joystick_radius
		var direction = offset / joystick_radius
		emit_signal("left_joystick_moved", direction)
	elif event.index == right_touch_index:
		var offset = event.position - right_origin
		var direction = offset / joystick_radius
		emit_signal("right_joystick_moved", direction)

func on_fire_button_pressed():
	emit_signal("fire_pressed")

func on_fire_button_released():
	emit_signal("fire_released")

func on_jump_button_pressed():
	emit_signal("jump_pressed")

func on_reload_button_pressed():
	emit_signal("reload_pressed")

func on_crouch_button_pressed():
	emit_signal("crouch_pressed")

func on_ads_button_pressed():
	emit_signal("ads_pressed")

func on_operator_button_pressed():
	emit_signal("operator_pressed")

func toggle_gyro(enabled: bool):
	gyro_enabled = enabled
	print("Gyroscope: ", "ON" if enabled else "OFF")
