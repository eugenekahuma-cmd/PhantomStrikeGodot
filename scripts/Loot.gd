extends Node3D

enum LootTier {COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}
enum LootType {WEAPON, AMMO, ARMOR, MEDKIT, GRENADE, OPERATOR_SHARD}

class LootItem:
	var item_name: String
	var loot_type: LootType
	var tier: LootTier
	var quantity: int

	func _init(name: String, type: LootType, t: LootTier, qty: int = 1):
		item_name = name
		loot_type = type
		tier = t
		quantity = qty

# Loot tables
var weapon_pool = {
	LootTier.COMMON: ["Vector-S", "P-Shadow"],
	LootTier.UNCOMMON: ["AK-Phantom", "M-Breacher"],
	LootTier.RARE: ["SR-Ghost", "LMG-Storm"],
	LootTier.EPIC: ["SR-Ghost Elite", "AK-Phantom Pro"],
	LootTier.LEGENDARY: ["Phantom Blade", "Ghost Sniper"]
}

var spawn_points: Array = []
var spawned_items: Array = []

signal item_spawned(item, position)
signal item_collected(item, player)

func _ready():
	print("Loot Manager ready!")

func spawn_loot_at(position: Vector3, tier: LootTier = LootTier.COMMON):
	var item = generate_random_item(tier)
	spawned_items.append({
		"item": item,
		"position": position,
		"collected": false
	})
	emit_signal("item_spawned", item, position)
	print("Loot spawned: ", item.item_name, " at ", position)

func generate_random_item(tier: LootTier) -> LootItem:
	var roll = randf()
	if roll < 0.4:
		return generate_weapon(tier)
	elif roll < 0.6:
		return LootItem.new("Ammo Pack", LootType.AMMO, tier, 30)
	elif roll < 0.75:
		return LootItem.new("Medkit", LootType.MEDKIT, tier)
	elif roll < 0.88:
		return LootItem.new("Armor", LootType.ARMOR, tier)
	elif roll < 0.95:
		return LootItem.new("Grenade", LootType.GRENADE, tier)
	else:
		return LootItem.new("Operator Shard", LootType.OPERATOR_SHARD, tier)

func generate_weapon(tier: LootTier) -> LootItem:
	var pool = weapon_pool[tier]
	var weapon_name = pool[randi() % pool.size()]
	return LootItem.new(weapon_name, LootType.WEAPON, tier)

func collect_item(item_index: int, player: Node):
	if item_index < spawned_items.size():
		var loot = spawned_items[item_index]
		if not loot.collected:
			loot.collected = true
			emit_signal("item_collected", loot.item, player)
			handle_collection(loot.item, player)

func handle_collection(item: LootItem, player: Node):
	match item.loot_type:
		LootType.WEAPON:
			if player.has_method("pick_up_weapon"):
				player.pick_up_weapon(item.item_name)
		LootType.MEDKIT:
			if player.has_method("heal"):
				player.heal(50.0)
		LootType.GRENADE:
			print("Grenade added to inventory!")
		LootType.ARMOR:
			print("Armor equipped!")
	print("Collected: ", item.item_name)

func spawn_loot_wave(count: int, area_center: Vector3, radius: float):
	for i in range(count):
		var random_offset = Vector3(
			randf_range(-radius, radius),
			0,
			randf_range(-radius, radius)
		)
		var tier = get_random_tier()
		spawn_loot_at(area_center + random_offset, tier)

func get_random_tier() -> LootTier:
	var roll = randf()
	if roll < 0.40: return LootTier.COMMON
	elif roll < 0.65: return LootTier.UNCOMMON
	elif roll < 0.85: return LootTier.RARE
	elif roll < 0.95: return LootTier.EPIC
	else: return LootTier.LEGENDARY
