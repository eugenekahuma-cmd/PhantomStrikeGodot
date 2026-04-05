extends Node

enum Difficulty {RECON, ASSAULT, PHANTOM}
enum ObjectiveType {HOSTAGE_RESCUE, DATA_EXTRACTION, DEMOLITION, ELIMINATION, DEFEND}
enum RaidState {BRIEFING, ACTIVE, COMPLETED, FAILED}

class Objective:
	var type: ObjectiveType
	var description: String
	var is_completed: bool
	var time_limit: float

	func _init(obj_type: ObjectiveType, desc: String, limit: float = 0.0):
		type = obj_type
		description = desc
		is_completed = false
		time_limit = limit

var difficulty: Difficulty = Difficulty.ASSAULT
var raid_state: RaidState = RaidState.BRIEFING
var objectives: Array = []
var shared_revives: int = 3
var elapsed_time: float = 0.0
var players_alive: int = 4

signal objective_completed(objective)
signal raid_completed
signal raid_failed(reason)
signal revive_used(revives_left)

func _ready():
	print("Shadow Raid ready!")
	setup_objectives()

func setup_objectives():
	objectives.clear()
	objectives.append(Objective.new(
		ObjectiveType.HOSTAGE_RESCUE,
		"Rescue the hostage from Sector B",
		300.0
	))
	objectives.append(Objective.new(
		ObjectiveType.DATA_EXTRACTION,
		"Extract data from the server room",
		0.0
	))
	objectives.append(Objective.new(
		ObjectiveType.DEMOLITION,
		"Plant charges on the power grid",
		0.0
	))

func start_raid():
	raid_state = RaidState.ACTIVE
	print("Shadow Raid started! Difficulty: ", Difficulty.keys()[difficulty])

func _process(delta):
	if raid_state != RaidState.ACTIVE:
		return
	elapsed_time += delta
	check_time_limits(delta)

func check_time_limits(delta):
	for objective in objectives:
		if not objective.is_completed and objective.time_limit > 0:
			objective.time_limit -= delta
			if objective.time_limit <= 0:
				fail_raid("Time limit exceeded!")

func complete_objective(index: int):
	if index < objectives.size():
		objectives[index].is_completed = true
		emit_signal("objective_completed", objectives[index])
		print("Objective completed: ", objectives[index].description)
		check_all_objectives()

func check_all_objectives():
	var all_done = true
	for obj in objectives:
		if not obj.is_completed:
			all_done = false
			break
	if all_done:
		complete_raid()

func complete_raid():
	raid_state = RaidState.COMPLETED
	emit_signal("raid_completed")
	print("Shadow Raid completed!")

func fail_raid(reason: String):
	raid_state = RaidState.FAILED
	emit_signal("raid_failed", reason)
	print("Raid failed: ", reason)

func use_shared_revive(player: Node):
	if shared_revives <= 0:
		fail_raid("All players eliminated!")
		return
	shared_revives -= 1
	emit_signal("revive_used", shared_revives)
	print("Revive used! Remaining: ", shared_revives)

func get_difficulty_multiplier() -> float:
	match difficulty:
		Difficulty.RECON: return 0.7
		Difficulty.ASSAULT: return 1.0
		Difficulty.PHANTOM: return 1.6
	return 1.0
