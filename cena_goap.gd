extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WorldState.set_state("player_visible", true)  # Jogador visível
	WorldState.set_state("player_dead", false)  # Jogador está morto
	WorldState.set_state("player_in_range", false)
	WorldState.set_state("player_instance", $player)
	
	print("Estado Atual:", WorldState._state)
