extends Area2D

var velocity : float = 100.0
var direction : int = 1
var player : Node2D


func _ready():
	player = get_node("/root/Node2D/player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func move(delta):
	if player:  # Verifica se o jogador foi atribuído corretamente
		move_towards_player(delta)

func move_towards_player(delta):
	var direction = (player.position - position).normalized()  # Calcula a direção para o jogador
	position += direction * velocity * delta  # Move a bola na direção do jogador com base na velocidade
