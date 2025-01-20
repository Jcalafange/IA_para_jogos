extends Node

class_name GoapActionPlanner

var _actions: Array

func set_actions(actions: Array):
	_actions = actions

func get_plan(goal: GoapGoal, blackboard = {}) -> Array:
	print("Planejar")
	print("Goal: %s" % goal.get_clazz())
	WorldState.console_message("Goal: %s" % goal.get_clazz())
	
	var desired_state = goal.get_desired_state().duplicate()
	print("Planejamento quer: %s" % str(desired_state))

	if desired_state.is_empty():
		print("Planejamento falhou: estado desejado vazio")
		return []

	return _find_best_plan(goal, desired_state, blackboard)

func _find_best_plan(goal, desired_state, blackboard):
	print("Procurando o melhor plano...")

	var root = {
		"action": goal,
		"state": desired_state,
		"children": []
	}
	print("Estado inicial da raiz: %s" % str(desired_state))
	
	if _build_plans(root, blackboard.duplicate()):
		print("Planos construídos com sucesso.")
		var plans = _transform_tree_into_array(root, blackboard)
		return _get_cheapest_plan(plans)
	
	print("Falha ao construir planos.")
	return []

func _get_cheapest_plan(plans):
	print("Obtendo o plano mais barato...")

	var best_plan
	for p in plans:
		_print_plan(p)
		if best_plan == null or p.cost < best_plan.cost:
			best_plan = p

	if best_plan != null:
		print("Plano mais barato encontrado.")
	else:
		print("Nenhum plano encontrado.")
		
	return best_plan.actions if best_plan != null else []

func _build_plans(step, blackboard):
	print("Construindo planos para o passo: %s" % str(step.state))
	var has_followup = false
	var state = step.state.duplicate()

	for s in step.state:
		if state[s] == blackboard.get(s):
			state.erase(s)

	if state.is_empty():
		print("Estado vazio após verificação de pré-condições.")
		return true

	print("Ações disponíveis para tentar...")
	if(_actions.size() == 0):
		print("Não tem ações")
	for action in _actions:
		print(action.get_clazz())
		if not action.is_valid():
			print("Ação %s é inválida, pulando." % action.get_clazz())
			continue

		var should_use_action = false
		var effects = action.get_effects()
		var desired_state = state.duplicate()

		print("Efeitos da ação %s: %s" % [action.get_clazz(), str(effects)])

		for s in desired_state:
			if desired_state[s] == effects.get(s):
				desired_state.erase(s)
				should_use_action = true

		if should_use_action:
			print("Usando ação %s para modificar o estado desejado." % action.get_clazz())
			
			var preconditions = action.get_preconditions()
			for p in preconditions:
				desired_state[p] = preconditions[p]

			var s = {
				"action": action,
				"state": desired_state,
				"children": []
			}

			if desired_state.is_empty() or _build_plans(s, blackboard.duplicate()):
				print("Plano válido encontrado, adicionando como filho.")
				step.children.push_back(s)
				has_followup = true
			else:
				print("Falha ao construir plano para ação %s" % action.get_clazz())

	return has_followup

func _transform_tree_into_array(p, blackboard):
	print("Transformando árvore de plano para array...")

	var plans = []
	if p.children.size() == 0:
		plans.push_back({ "actions": [p.action], "cost": p.action.get_cost(blackboard) })
		return plans

	for c in p.children:
		for child_plan in _transform_tree_into_array(c, blackboard):
			if p.action.has_method("get_cost"):
				child_plan.actions.push_back(p.action)
				child_plan.cost += p.action.get_cost(blackboard)
			plans.push_back(child_plan)

	print("Plano transformado em array. Total de planos: %d" % plans.size())
	return plans

func _print_plan(plan):
	var actions = []
	for a in plan.actions:
		actions.push_back(a.get_clazz())
	print({"cost": plan.cost, "actions": actions})
	WorldState.console_message({"cost": plan.cost, "actions": actions})
