extends GoapGoal

class_name ChasePlayerGoal

func get_clazz():
	return "ChasePlayerGoal"

func is_valid() -> bool:
	return not WorldState.get_state("player_in_range", false) and not WorldState.get_state("enemy_need_heal", false) 

# Define a prioridade para seguir o jogador
func priority() -> int:
	return 2

# Estado desejado: jogador está a 100 unidades de distância
func get_desired_state() -> Dictionary:
	return {
		"player_in_range": true
	}
