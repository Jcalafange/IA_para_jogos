extends Area2D


class_name ballController

var velocity : float = 100.0
var direction : int = 1
signal destruct_ball
var player : Node2D

func _ready():
	connect("area_entered", Callable(self, "_on_bullet_body_entered"))

func _ready():
	player = get_node("/root/Node2D/player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func move(delta):
	if player:  # Verifica se o jogador foi atribuído corretamente
		move_towards_player(delta)

func _on_bullet_body_entered(body):
	if body.is_in_group("bullets"):
		body.queue_free()
		emit_signal("destruct_ball", self)
		queue_free()
    
func move_towards_player(delta):
	var direction = (player.position - position).normalized()  # Calcula a direção para o jogador
	position += direction * velocity * delta  # Move a bola na direção do jogador com base na velocidade
