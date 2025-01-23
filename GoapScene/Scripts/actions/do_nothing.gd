extends GoapAction

class_name DoNothing

func get_clazz():
	return "DoNothing"

# Define o custo da ação
func get_cost(_blackboard) -> int:
	return 5

# Pré-condições para executar esta ação
func get_preconditions() -> Dictionary:
	return {
		"player_in_range": true
	}

# Efeitos da ação: jogador está ao alcance
func get_effects() -> Dictionary:
	return {
		"player_in_range": false
	}

# Lógica para seguir o jogador
func perform(actor, delta) -> bool:
	var player = WorldState.get_state("player_instance", null)
	if player == null:
		return false

	if actor.position.distance_to(player.position) > 50:
		print("Jogador está ao alcance do inimigo.")
		WorldState.set_state("player_in_range", false)
		return true  
	return false
