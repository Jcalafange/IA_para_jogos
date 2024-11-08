extends Area2D

signal collected  # Sinal para notificar quando o power-up é coletado

func _ready():
	# Conecta o sinal 'body_entered' a esta função
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is CharacterBody2D:  # Verifica se o jogador entrou
		emit_signal("collected")  # Emite o sinal para o script do jogador
		queue_free()  # Remove o power-up da cena
