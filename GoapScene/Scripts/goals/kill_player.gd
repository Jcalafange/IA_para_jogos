extends GoapGoal

class_name KillPlayerGoal

func get_clazz(): 
	return "KillPlayerGoal"

# O objetivo de matar o jogador é válido quando o jogador está ao alcance do inimigo.
func is_valid() -> bool:
	return WorldState.get_state("player_in_range", false)

func priority() -> int:
	return 3

# Estado desejado: o jogador morreu.
func get_desired_state() -> Dictionary:
	return {
		"player_dead": true  # Indica que o jogador foi morto
	}
