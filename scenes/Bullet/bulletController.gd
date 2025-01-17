extends Area2D
class_name bulletController

var direction : Vector2
var speed : int = 250
var damage : float = 30.0
@export var lifetime: float = 0.5
@export var creator: String

# Called when the node enters the scene tree for the first time.
func _ready():
	$LifetimeTimer.start(lifetime)
	print("Bala Criada")
	$LifetimeTimer.connect("timeout", Callable(self, "_on_LifetimeTimer_timeout"))

func _on_LifetimeTimer_timeout():
	print("desstruir bala")
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += speed * direction * delta

func get_creator() -> String:
	return creator


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemys") and creator == "player":
		body.takeDamage(35)
	elif body.is_in_group("Player") and creator != "player":
		body.takeDamage(15)
	
