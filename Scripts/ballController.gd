extends Area2D

class_name ballController

var velocity : float = 100.0
var direction : int = 1
signal destruct_ball

func _ready():
	connect("area_entered", Callable(self, "_on_bullet_body_entered"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_bullet_body_entered(body):
	if body.is_in_group("bullets"):
		body.queue_free()
		emit_signal("destruct_ball", self)
		queue_free()


func move(minX: float, maxX: float):
	position.x += velocity * direction * get_process_delta_time()
	if position.x <= minX:
		direction = 1  # Muda a direção para direita
	elif position.x >= maxX:
		direction = -1  # Muda a direção para esquerda
