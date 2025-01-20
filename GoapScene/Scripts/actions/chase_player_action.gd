extends GoapAction

class_name ChasePlayerAction

func get_clazz(): 
	return "ChasePlayerAction"

# Define o custo da ação com base na distância até o jogador.
func get_cost(_blackboard) -> int:
	var actor = _blackboard.get("actor")
	var player = _blackboard.get("player")
	return actor.position.distance_to(player.position)

# Pré-condições para executar esta ação.
func get_preconditions() -> Dictionary:
	return {
		"player_visible": true
	}

# Efeitos da ação: o jogador está ao alcance.
func get_effects() -> Dictionary:
	return {
		"player_in_range": true
	}

# Lógica para executar a perseguição.
func perform(actor, delta) -> bool:
	var player = WorldState.get_state("player_instance", null)
	if player == null:
		return false

	var direction = actor.position.direction_to(player.position)
	actor.move_to(direction, delta)

	# Verifica se o inimigo está próximo o suficiente do jogador.
	if actor.position.distance_to(player.position) < 10:
		# Quando o inimigo está perto, causa dano ao jogador
		if player.has_method("currentLife"):
			player.currentLife -= 10  # Diminui 10 da vida do jogador

		# Verifica se a vida do jogador chegou a zero
		if player.currentLife <= 0:
			# O jogador morre
			WorldState.set_state("player_dead", true)
			return true

		return true  # O inimigo atingiu o jogador

	return false  # O inimigo ainda está perseguindo o jogador
