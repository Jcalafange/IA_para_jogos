extends Node

var _action_planner =  GoapActionPlanner.new()

func _ready():
	_action_planner.set_actions([
		ChasePlayerAction.new(),
		StayAction.new(),
		DoNothing.new(),
		ChaseHealerAction.new()
	])


func get_action_planner() -> GoapActionPlanner:
	return _action_planner
