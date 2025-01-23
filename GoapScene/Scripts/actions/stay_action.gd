extends GoapAction

class_name StayAction

func get_clazz():
	return "StayAction"

# Define o custo da ação
func get_cost(_blackboard) -> int:
	return 5

# Pré-condições para executar esta ação
func get_preconditions() -> Dictionary:
	return {
		"stay": true
	}

# Efeitos da ação: jogador está ao alcance
func get_effects() -> Dictionary:
	return {
		"enemy_need_heal": false
	}

# Lógica para seguir o jogador
func perform(actor, delta) -> bool:
	var player = WorldState.get_state("player_instance", null)
	if player == null:
		return false

	if actor.currentLife > 50 and actor.currentLife < 70:
		WorldState.set_state("enemy_need_heal", false)
		return true  
	return false
