extends GoapGoal

class_name KillPlayerGoal

func get_clazz(): 
	return "KillPlayerGoal"

# O objetivo é válido apenas se o jogador estiver visível.
func is_valid() -> bool:
	return WorldState.get_state("player_visible", false)

# Define a prioridade para o objetivo. Pode ser mais alta, pois "matar" é um objetivo importante.
func priority() -> int:
	return 3  # Definido para ser mais alto do que perseguir.

# Estado desejado: o jogador está morto.
func get_desired_state() -> Dictionary:
	return {
		"player_dead": true
	}
