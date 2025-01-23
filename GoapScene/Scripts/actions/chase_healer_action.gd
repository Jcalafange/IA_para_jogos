extends GoapAction

class_name ChaseHealerAction

func get_clazz():
	return "ChaseHealerAction"

# Define o custo da ação
func get_cost(_blackboard) -> int:
	return 5

func get_preconditions() -> Dictionary:
	return {
		"enemy_need_heal": true
	}

func get_effects() -> Dictionary:
	return {
		"stay": true
	}

# Lógica para seguir o jogador
func perform(actor, delta) -> bool:
	var healer = WorldState.get_state("healer_instance", null)
	if healer == null:
		return false

	var direction = actor.position.direction_to(healer.position)
	actor.velocity = direction * 100
	actor.move_to(direction, delta)

	# Verifica a distância até o jogador
	if actor.position.distance_to(healer.position) <= 5:
		WorldState.set_state("stay", true)
		return true  # Jogador está dentro do alcance
	return false
