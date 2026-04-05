extends Node

const MAX_WEAPONS = 2
const MAX_GRENADES = 3
const MAX_MEDKITS = 2

class Item:
	var item_name: String
	var item_type: String
	var quantity: int

	func _init(name: String, type: String, qty: int = 1):
		item_name = name
		item_type = type
		quantity = qty

var weapons: Array = []
var active_weapon_index: int = 0
var grenades: int = 0
var medkits: int = 0
var armor_level: int = 0
var backpack_level: int = 0

signal weapon_switched(weapon)
signal item_picked_up(item_name)
signal item_used(item_name)
signal inventory_full

func _ready():
	print("Inventory ready!")

func pick_up_weapon(weapon_name: String) -> bool:
	if weapons.size() >= MAX_WEAPONS:
		emit_signal("inventory_full")
		print("Weapon slots full!")
		return false
	var weapon = Item.new(weapon_name, "weapon")
	weapons.append(weapon)
	emit_signal("item_picked_up", weapon_name)
	print("Picked up: ", weapon_name)
	return true

func switch_weapon():
	if weapons.size() < 2:
		return
	active_weapon_index = 1 if active_weapon_index == 0 else 0
	emit_signal("weapon_switched", weapons[active_weapon_index])
	print("Switched to: ", weapons[active_weapon_index].item_name)

func get_active_weapon() -> Item:
	if weapons.size() > active_weapon_index:
		return weapons[active_weapon_index]
	return null

func pick_up_grenade() -> bool:
	if grenades >= MAX_GRENADES:
		print("Max grenades reached!")
		return false
	grenades += 1
	emit_signal("item_picked_up", "Grenade")
	print("Grenades: ", grenades)
	return true

func use_grenade() -> bool:
	if grenades <= 0:
		print("No grenades!")
		return false
	grenades -= 1
	emit_signal("item_used", "Grenade")
	return true

func pick_up_medkit() -> bool:
	if medkits >= MAX_MEDKITS:
		print("Max medkits reached!")
		return false
	medkits += 1
	emit_signal("item_picked_up", "Medkit")
	return true

func use_medkit(player: Node) -> bool:
	if medkits <= 0:
		print("No medkits!")
		return false
	medkits -= 1
	if player.has_method("heal"):
		player.heal(50.0)
	emit_signal("item_used", "Medkit")
	print("Medkit used! Medkits left: ", medkits)
	return true

func pick_up_armor(level: int):
	if level > armor_level:
		armor_level = level
		emit_signal("item_picked_up", "Armor Level " + str(level))
		print("Armor upgraded to level: ", armor_level)

func get_inventory_summary() -> String:
	var summary = "Weapons: " + str(weapons.size()) + "/" + str(MAX_WEAPONS)
	summary += " | Grenades: " + str(grenades)
	summary += " | Medkits: " + str(medkits)
	summary += " | Armor: " + str(armor_level)
	return summary
