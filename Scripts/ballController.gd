extends Area2D


class_name ballController

var velocity : float = 25.0
var direction : int = 1
var maxLife: float = 100.0
var currentLife: float = 0.0
signal destruct_ball
var player : Node2D

signal entered_zone(zone)  # Novo sinal para quando a bola entra em uma zona
signal exited_zone(zone)   # Novo sinal para quando a bola sai de uma zona

var hpBar : ColorRect
var lifeBar : ColorRect

func _ready():
	connect("area_entered", Callable(self, "_on_bullet_body_entered"))
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_exited", Callable(self, "_on_area_exited"))
	player = get_node("/root/Node2D/player")
	currentLife = maxLife
	
	hpBar = $Hp  
	lifeBar = hpBar.get_node("Bar")

func _process(delta):
	update_life_bar()

func move(delta):
	if player:  # Verifica se o jogador foi atribuído corretamente
		move_towards_player(delta)

func _on_bullet_body_entered(body):
	if body.is_in_group("bullets"):
		body.queue_free()
		currentLife -= 30
		if(currentLife <= 0):
			emit_signal("destruct_ball", self)
			queue_free()

# Detecta quando a bola entra em uma zona
func _on_area_entered(area: Area2D):
	if area is ZoneController:  # Verifica se a área com a qual a bola colidiu é uma zona
		emit_signal("entered_zone", area, self)  # Emite o sinal para o GameController

# Detecta quando a bola sai de uma zona
func _on_area_exited(area: Area2D):
	if area is ZoneController:
		emit_signal("exited_zone", area, self)

func move_towards_player(delta):
	var direction = (player.position - position).normalized()  # Calcula a direção para o jogador
	position += direction * velocity * delta  # Move a bola na direção do jogador com base na velocidade

func update_life_bar():
	if lifeBar:
		var life_percentage = currentLife / maxLife
		
		lifeBar.size.x = hpBar.size.x * life_percentage
