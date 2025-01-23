extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WorldState.set_state("player_in_range", false)
	WorldState.set_state("enemy_need_heal", false)
	WorldState.set_state("stay", false)
	WorldState.set_state("player_instance", $player)
	WorldState.set_state("healer_instance", $EnemyHealer)
	
