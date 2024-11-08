extends Area2D


class_name ballController

enum State {
	NORMAL,
	FLEEING
}

var velocity : float = 15.0
var direction : int = 1
var maxLife: float = 100.0
var currentLife: float = 0.0
signal destruct_ball
var player : Node2D

var currentState: State = State.NORMAL 
var fleeDistance: float = 200.0

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
	
	currentState = State.NORMAL

func _process(delta):
	update_life_bar()

func move(delta):
	update_state()
	match currentState:
		State.NORMAL:
			move_towards_player(delta)
		State.FLEEING:
			move_away_from_player(delta)

func _on_bullet_body_entered(body):
	if body.is_in_group("bullets"):
		body.queue_free()
		currentLife -= 30
		if(currentLife <= 0):
			emit_signal("destruct_ball", self)
			queue_free()

# Detecta quando a bola entra em uma zona
func _on_area_entered(area: ZoneController):
	if area is ZoneController:  # Verifica se a área com a qual a bola colidiu é uma zona
		emit_signal("entered_zone", area, self)  # Emite o sinal para o GameController

# Detecta quando a bola sai de uma zona
func _on_area_exited(area: ZoneController):
	if area is ZoneController:
		emit_signal("exited_zone", area, self)

func move_towards_player(delta):
	var direction = (player.position - position).normalized()  # Calcula a direção para o jogador
	position += direction * velocity * delta  # Move a bola na direção do jogador com base na velocidade

func update_life_bar():
	if lifeBar:
		var life_percentage = currentLife / maxLife
		lifeBar.size.x = hpBar.size.x * life_percentage

func update_state():
	if currentLife <= (maxLife * 0.3):  # Se a vida do inimigo for menor que 30%, ele entra no estado de fuga
		if currentState != State.FLEEING:
			currentState = State.FLEEING
			print("Entrando no estado de fuga")
	else:
		if currentState != State.NORMAL:
			currentState = State.NORMAL
			print("Voltando ao estado normal")

# Move o inimigo para longe do jogador (fuga)
func move_away_from_player(delta):
	var distance_to_player = position.distance_to(player.position)  # Calcula a distância atual até o jogador
	print("Distancia do Player: ", distance_to_player)
	if distance_to_player < fleeDistance:  # Se a distância for maior que a distância de fuga
		var direction = (position - player.position).normalized()  # Direção para longe do jogador
		position += direction * velocity * delta  # Move o inimigo para longe
	else:
		# Se a bola estiver a uma distância menor ou igual a fleeDistance, ela para
		print("Distância de fuga alcançada, parado.")
