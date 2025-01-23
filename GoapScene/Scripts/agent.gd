extends Node

class_name  GoapAgent

var _goals
var _current_goal
var _current_plan
var _current_plan_step = 0

var _actor

func _process(delta):
	var goal = _get_best_goal()
	
	# Verifica se o objetivo atual é nulo ou se o objetivo mudou
	if _current_goal == null or goal != _current_goal:
		var blackboard = {
			"position": _actor.position,
		}
		
		# Preenche o blackboard com o estado atual do mundo
		for s in WorldState._state:
			blackboard[s] = WorldState._state[s]
			#print(s)

		_current_goal = goal
		#print("Current plan: ", _current_goal.get_clazz())
		#print("State desired plan: ", _current_goal.get_desired_state())
		_current_plan = Goap.get_action_planner().get_plan(_current_goal, blackboard)
		_current_plan_step = 0
	else:
		_follow_plan(_current_plan, delta)  # Segue o plano gerado

func init(actor, goals: Array):
	_actor = actor
	_goals = goals

func _get_best_goal():
	var highest_priority_goal = null
	# Percorre todos os objetivos e encontra o com a maior prioridade
	for goal in _goals:
		if goal.is_valid():
			if highest_priority_goal == null or goal.priority() > highest_priority_goal.priority():
				highest_priority_goal = goal
	return highest_priority_goal

func _follow_plan(plan, delta):
	#print("Tamanho do plano: ", plan.size())
	if plan.size() == 0:
		return

	var is_step_complete = plan[_current_plan_step].perform(_actor, delta)
	#print("step plan: ", _current_plan_step)

	if is_step_complete:
		if _current_plan_step < plan.size() - 1:
			_current_plan_step += 1  # Passa para o próximo passo do plano
		else:
			#print("Plano concluído.")
			_current_goal = null 
