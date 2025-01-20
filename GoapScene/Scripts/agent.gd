extends Node

class_name  GoapAgent
# Called when the node enters the scene tree for the first time.
var _goals
var _current_goal
var _current_plan
var _current_plan_step = 0

var _actor
func _ready() -> void:
	print("Planejador Preparado")

func _process(delta):
	var goal = _get_best_goal()
	if _current_goal == null or goal != _current_goal:
		var blackboard = {
				"position": _actor.position,
				}
				
		for s in WorldState._state:
			blackboard[s] = WorldState._state[s]
			print(s)

		_current_goal = goal
		_current_plan = Goap.get_action_planner().get_plan(_current_goal, blackboard)
		_current_plan_step = 0
		
		if _current_plan.size() > 0:
			print("Plano gerado:", _current_plan)
		else:
			print("Nenhum plano gerado.")
			
	else:
		_follow_plan(_current_plan, delta)

func init(actor, goals: Array):
	_actor = actor
	_goals = goals

func _get_best_goal():
	var highest_priority

	for goal in _goals:
		if goal.is_valid() and (highest_priority == null or goal.priority() > highest_priority.priority()):
			highest_priority = goal

	return highest_priority

func _follow_plan(plan, delta):
	if plan.size() == 0:
		return

	var is_step_complete = plan[_current_plan_step].perform(_actor, delta)
	if is_step_complete and _current_plan_step < plan.size() - 1:
		_current_plan_step += 1
