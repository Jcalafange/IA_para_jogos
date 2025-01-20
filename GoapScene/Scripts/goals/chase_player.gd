extends GoapGoal

class_name ChasePlayerGoal

func get_clazz(): 
	return "ChasePlayerGoal"

# O objetivo é válido apenas se o jogador estiver na cena.
func is_valid() -> bool:
	return WorldState.get_state("player_visible", false)

# Define a prioridade para o objetivo.
func priority() -> int:
	return 2

# Estado desejado: o jogador está em alcance.
func get_desired_state() -> Dictionary:
	return {
		"player_in_range": true
	}
