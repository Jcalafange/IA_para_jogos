extends CharacterBody2D

@export var speed: float = 25.0

@onready var player = $"../../player" 

# Move em direção ao jogador
func move_towards_player(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed

func move(delta):
	move_towards_player(delta)
	move_and_slide()
