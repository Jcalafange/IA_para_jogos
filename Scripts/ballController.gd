extends Area2D


var velocity : float = 100.0
var direction : int = 1

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move(minX: float, maxX: float):
	position.x += velocity * direction * get_process_delta_time()
	if position.x <= minX:
		direction = 1  # Muda a direção para direita
	elif position.x >= maxX:
		direction = -1  # Muda a direção para esquerda
