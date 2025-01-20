extends GoapAction

class_name KillPlayerAction

func get_clazz(): 
	return "KillPlayerAction"

# Define o custo da ação de matar o jogador (ex: pode depender da vida do inimigo)
func get_cost(_blackboard) -> int:
	return 5  # O custo pode ser ajustado

# Pré-condições para executar a ação de matar.
func get_preconditions() -> Dictionary:
	return {
		"player_in_range": true  # O jogador precisa estar ao alcance para ser morto
	}

# Efeitos da ação de matar: jogador morto.
func get_effects() -> Dictionary:
	return {
		"player_dead": true
	}

# Executa a lógica de matar o jogador.
func perform(actor, delta) -> bool:
	var player = WorldState.get_state("player_instance", null)
	if player != null:
		player.currentLife = 0  # Define a vida do jogador como 0 para simular a morte
		return true  # O inimigo matou o jogador
	return false
