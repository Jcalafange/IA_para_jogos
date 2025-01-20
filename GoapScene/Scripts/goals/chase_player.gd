extends GoapGoal

class_name ChasePlayerGoal

func get_clazz(): 
	return "ChasePlayerGoal"

# O objetivo é válido apenas se o jogador estiver na cena.
func is_valid() -> bool:
	return WorldState.get_state("player_visible", false)  # Verifica se o jogador está visível

# Define a prioridade para o objetivo.
func priority() -> int:
	return 2  # A prioridade pode ser ajustada dependendo da situação do jogo.

# Estado desejado: o jogador está em alcance.
func get_desired_state() -> Dictionary:
	return {
		"player_in_range": true  # O estado desejado é que o jogador esteja dentro do alcance do inimigo
	}
