extends Area2D

# Tempo entre regenerações (em segundos)
@export var regeneration_interval: float = 2.0
# Quantidade de vida regenerada por intervalo
@export var regeneration_amount: int = 10

# Lista de inimigos na área
var enemies_in_area: Array

# Temporizador para regeneração
@onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = regeneration_interval
	timer.start()

func _on_body_entered(body: Node2D) -> void:
	print("Curar")
	if body.is_in_group("Enemies"):
		print("Curar")
		enemies_in_area.append(body) # Replace with function body.


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		enemies_in_area.erase(body)


func _on_timer_timeout() -> void:
	for enemy in enemies_in_area:
		if enemy.has_method("regenerate_health") and enemy.currentLife < 100:
			enemy.regenerate_health(regeneration_amount) # Replace with function body.
