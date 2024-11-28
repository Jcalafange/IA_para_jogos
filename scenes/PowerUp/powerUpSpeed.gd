extends Area2D

signal collected  # Sinal para notificar quando o power-up é coletado

func _ready():
	# Conecta o sinal 'body_entered' a esta função
	add_to_group("powerups")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is CharacterBody2D:
		emit_signal("collected")
		queue_free()
	elif body is ballController:
		body.restore_life(50)  # Ajuste o valor conforme necessário
		queue_free()
