extends Node

enum GameMode {WRAITH_STORM, SHADOW_RAID, TACTICAL_ROYALE, GHOST_PROTOCOL}
enum MatchState {WAITING, SKYDIVE, ACTIVE, FINAL_CIRCLE, ENDED}

@export var max_players: int = 40
@export var game_mode: GameMode = GameMode.WRAITH_STORM

var match_state: MatchState = MatchState.WAITING
var players_alive: int = 0
var squads_alive: int = 0
var player_kills: int = 0

signal match_started
signal match_ended(winner)
signal player_died(player)
signal wraith_wave_spawned(count)

func _ready():
	print("Game Manager ready!")
	print("Mode: ", GameMode.keys()[game_mode])

func start_match():
	match_state = MatchState.SKYDIVE
	players_alive = max_players
	emit_signal("match_started")
	print("Match started!")
	await get_tree().create_timer(45.0).timeout
	begin_active_phase()

func begin_active_phase():
	match_state = MatchState.ACTIVE
	if game_mode == GameMode.WRAITH_STORM:
		start_wraith_storm()

func start_wraith_storm():
	spawn_wraith_wave(5)
	await get_tree().create_timer(60.0).timeout
	spawn_wraith_wave(10)
	await get_tree().create_timer(60.0).timeout
	spawn_wraith_wave(20)
	await get_tree().create_timer(60.0).timeout
	trigger_final_circle()

func spawn_wraith_wave(count: int):
	emit_signal("wraith_wave_spawned", count)
	print("Wraith wave spawned: ", count, " wraiths!")

func trigger_final_circle():
	match_state = MatchState.FINAL_CIRCLE
	print("Final circle! Wraith Boss incoming!")
	spawn_wraith_wave(1)

func on_player_died(player):
	players_alive -= 1
	emit_signal("player_died", player)
	print("Players remaining: ", players_alive)
	check_win_condition()

func check_win_condition():
	if players_alive <= 1:
		end_match()

func end_match():
	match_state = MatchState.ENDED
	emit_signal("match_ended", "Last Squad Standing!")
	print("Match Over!")

func add_kill():
	player_kills += 1
	print("Kills: ", player_kills)
