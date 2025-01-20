extends Node

var _action_planner =  GoapActionPlanner.new()

func _ready():
	print("Goap Ativo")
	_action_planner.set_actions([
		ChasePlayerAction.new(),
		KillPlayerAction.new()
	])


func get_action_planner() -> GoapActionPlanner:
	return _action_planner
