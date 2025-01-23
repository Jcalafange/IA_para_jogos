extends GoapAction

class_name ChasePlayerAction

func get_clazz():
	return "ChasePlayerAction"

# Define o custo da ação
func get_cost(_blackboard) -> int:
	return 5

# Pré-condições para executar esta ação
func get_preconditions() -> Dictionary:
	return {
		"player_in_range": false
	}

# Efeitos da ação: jogador está ao alcance
func get_effects() -> Dictionary:
	return {
		"player_in_range": true
	}

# Lógica para seguir o jogador
func perform(actor, delta) -> bool:
	var player = WorldState.get_state("player_instance", null)
	if player == null:
		return false

	var direction = actor.position.direction_to(player.position)
	actor.velocity = direction * 100
	actor.move_to(direction, delta)

	# Verifica a distância até o jogador
	if actor.position.distance_to(player.position) <= 50:
		print("Jogador está ao alcance do inimigo.")
		WorldState.set_state("player_in_range", true)
		WorldState.set_state("stay", false)
		return true  # Jogador está dentro do alcance
	return false
