extends CanvasLayer

# HUD References
@onready var health_bar = $HealthBar
@onready var armor_bar = $ArmorBar
@onready var ammo_label = $AmmoLabel
@onready var kills_label = $KillsLabel
@onready var alive_label = $AliveLabel
@onready var zone_timer = $ZoneTimer
@onready var crosshair = $Crosshair
@onready var operator_cooldown = $OperatorCooldown
@onready var squad_panel = $SquadPanel

# HUD State
var max_health: float = 100.0
var max_armor: float = 100.0

func _ready():
	print("HUD ready!")
	update_health(100.0)
	update_armor(0.0)
	update_ammo(30, 90)
	update_kills(0)
	update_alive(40)

func update_health(value: float):
	if health_bar:
		health_bar.value = (value / max_health) * 100
	if value < 30:
		health_bar.modulate = Color.RED
	else:
		health_bar.modulate = Color.GREEN

func update_armor(value: float):
	if armor_bar:
		armor_bar.value = (value / max_armor) * 100

func update_ammo(current: int, reserve: int):
	if ammo_label:
		ammo_label.text = str(current) + " / " + str(reserve)
	if current == 0:
		ammo_label.modulate = Color.RED
	else:
		ammo_label.modulate = Color.WHITE

func update_kills(kills: int):
	if kills_label:
		kills_label.text = str(kills)

func update_alive(count: int):
	if alive_label:
		alive_label.text = str(count)
	if count <= 5:
		alive_label.modulate = Color.RED
	else:
		alive_label.modulate = Color.WHITE

func update_zone_timer(seconds: float):
	if zone_timer:
		var minutes = int(seconds / 60)
		var secs = int(seconds) % 60
		zone_timer.text = str(minutes) + ":" + str(secs).pad_zeros(2)
	if seconds < 30:
		zone_timer.modulate = Color.RED
	else:
		zone_timer.modulate = Color.WHITE

func update_operator_cooldown(percent: float):
	if operator_cooldown:
		operator_cooldown.value = percent * 100

func show_kill_feed(killer: String, victim: String):
	print(killer + " eliminated " + victim)

func show_damage_indicator(direction: Vector3):
	pass

func toggle_crosshair(visible: bool):
	if crosshair:
		crosshair.visible = visible

