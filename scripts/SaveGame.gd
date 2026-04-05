extends Node

const SAVE_FILE = "user://phantom_strike_save.json"

var save_data = {
	"player_name": "Ghost",
	"level": 1,
	"xp": 0,
	"kills_total": 0,
	"matches_played": 0,
	"matches_won": 0,
	"operators_unlocked": ["Viper"],
	"weapons_unlocked": ["AK-Phantom", "P-Shadow"],
	"battle_pass_tier": 0,
	"settings": {
		"music_volume": 0.7,
		"sfx_volume": 1.0,
		"gyro_enabled": false,
		"graphics_quality": "medium"
	}
}

signal game_saved
signal game_loaded

func _ready():
	print("Save System ready!")
	load_game()

func save_game():
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		emit_signal("game_saved")
		print("Game saved!")
	else:
		print("Failed to save game!")

func load_game():
	if not FileAccess.file_exists(SAVE_FILE):
		print("No save file found — starting fresh!")
		save_game()
		return
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(content)
		if parsed:
			save_data = parsed
			emit_signal("game_loaded")
			print("Game loaded!")
		else:
			print("Save file corrupted!")

func update_stats(kills: int, won: bool):
	save_data.kills_total += kills
	save_data.matches_played += 1
	if won:
		save_data.matches_won += 1
	add_xp(kills * 100 + (500 if won else 0))
	save_game()

func add_xp(amount: int):
	save_data.xp += amount
	check_level_up()

func check_level_up():
	var xp_needed = save_data.level * 1000
	if save_data.xp >= xp_needed:
		save_data.xp -= xp_needed
		save_data.level += 1
		print("Level up! Now level: ", save_data.level)

func unlock_operator(operator_name: String):
	if operator_name not in save_data.operators_unlocked:
		save_data.operators_unlocked.append(operator_name)
		save_game()
		print("Operator unlocked: ", operator_name)

func unlock_weapon(weapon_name: String):
	if weapon_name not in save_data.weapons_unlocked:
		save_data.weapons_unlocked.append(weapon_name)
		save_game()
		print("Weapon unlocked: ", weapon_name)

func update_settings(key: String, value):
	save_data.settings[key] = value
	save_game()

func get_win_rate() -> float:
	if save_data.matches_played == 0:
		return 0.0
	return float(save_data.matches_won) / float(save_data.matches_played) * 100.0

func get_stats_summary() -> String:
	return "Level: " + str(save_data.level) + \
	" | Matches: " + str(save_data.matches_played) + \
	" | Wins: " + str(save_data.matches_won) + \
	" | Win Rate: " + str(snappedf(get_win_rate(), 0.1)) + "%"
