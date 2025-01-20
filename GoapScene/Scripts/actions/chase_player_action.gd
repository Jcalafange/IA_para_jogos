extends GoapAction

class_name ChasePlayerAction

func get_clazz(): 
	return "ChasePlayerAction"

# Define o custo da ação com base na distância até o jogador.
func get_cost(_blackboard) -> int:
	var actor = _blackboard.get("actor")
	var player = _blackboard.get("player")
	return 1

# Pré-condições para executar esta ação.
func get_preconditions() -> Dictionary:
	return {
		"player_visible": true  # O jogador precisa estar visível para a perseguição começar.
	}

# Efeitos da ação: o jogador está ao alcance.
func get_effects() -> Dictionary:
	return {
		"player_in_range": true  # Após a ação, o jogador está dentro do alcance do inimigo.
	}

# Lógica para executar a perseguição.
func perform(actor, delta) -> bool:
	var player = WorldState.get_state("player_instance", null)
	if player == null:
		return false

	var direction = actor.position.direction_to(player.position)
	actor.velocity = direction * 100
	actor.move_and_slide()  # Ajuste a velocidade de movimento conforme necessário

	# Verifica se o inimigo está próximo o suficiente do jogador.
	if actor.position.distance_to(player.position) < 10:  # Distância de "alcance" do jogador
		return true  # O inimigo alcançou o jogador

	return false  # O inimigo ainda está perseguindo
