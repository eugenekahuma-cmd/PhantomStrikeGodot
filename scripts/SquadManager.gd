extends Node

const MAX_SQUAD_SIZE = 5
const MAX_SQUADS = 8

enum SquadRole {LEADER, MEMBER}

class SquadMember:
	var player_name: String
	var operator_name: String
	var health: float
	var is_alive: bool
	var is_downed: bool
	var kills: int
	var role: SquadRole

	func _init(name: String, operator: String):
		player_name = name
		operator_name = operator
		health = 100.0
		is_alive = true
		is_downed = false
		kills = 0
		role = SquadRole.MEMBER

var squads: Array = []
var my_squad_index: int = 0
var my_member_index: int = 0

signal squad_member_downed(squad_index, member_index)
signal squad_member_died(squad_index, member_index)
signal squad_eliminated(squad_index)
signal revive_completed(member)

func _ready():
	print("Squad Manager ready!")

func create_squad(player_names: Array, operator_names: Array) -> int:
	var squad = []
	for i in range(min(player_names.size(), MAX_SQUAD_SIZE)):
		var member = SquadMember.new(player_names[i], operator_names[i])
		if i == 0:
			member.role = SquadRole.LEADER
		squad.append(member)
	squads.append(squad)
	return squads.size() - 1

func get_squad(squad_index: int) -> Array:
	if squad_index < squads.size():
		return squads[squad_index]
	return []

func on_member_downed(squad_index: int, member_index: int):
	var squad = get_squad(squad_index)
	if squad.size() > member_index:
		squad[member_index].is_downed = true
		squad[member_index].health = 15.0
		emit_signal("squad_member_downed", squad_index, member_index)
		print(squad[member_index].player_name, " is downed!")

func revive_member(squad_index: int, member_index: int):
	var squad = get_squad(squad_index)
	if squad.size() > member_index:
		var member = squad[member_index]
		if member.is_downed:
			await get_tree().create_timer(5.0).timeout
			member.is_downed = false
			member.health = 30.0
			emit_signal("revive_completed", member)
			print(member.player_name, " revived!")

func on_member_died(squad_index: int, member_index: int):
	var squad = get_squad(squad_index)
	if squad.size() > member_index:
		squad[member_index].is_alive = false
		squad[member_index].is_downed = false
		emit_signal("squad_member_died", squad_index, member_index)
		print(squad[member_index].player_name, " eliminated!")
		check_squad_eliminated(squad_index)

func check_squad_eliminated(squad_index: int):
	var squad = get_squad(squad_index)
	var all_dead = true
	for member in squad:
		if member.is_alive:
			all_dead = false
			break
	if all_dead:
		emit_signal("squad_eliminated", squad_index)
		print("Squad ", squad_index, " eliminated!")

func get_alive_squads() -> int:
	var count = 0
	for squad in squads:
		for member in squad:
			if member.is_alive:
				count += 1
				break
	return count

func update_member_health(squad_index: int, member_index: int, health: float):
	var squad = get_squad(squad_index)
	if squad.size() > member_index:
		squad[member_index].health = health
