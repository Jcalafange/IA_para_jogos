extends Area2D

var direction : Vector2
var speed : int = 250
var damage : float = 30.0
@export var lifetime: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	$LifetimeTimer.start(lifetime)
	$LifetimeTimer.connect("timeout", Callable(self, "_on_LifetimeTimer_timeout"))

func _on_LifetimeTimer_timeout():
	print("desstruir bala")
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += speed * direction * delta
