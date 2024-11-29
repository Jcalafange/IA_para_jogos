extends Area2D

class_name ballController

enum State {
	NORMAL,
	ATTACKING,
	FLEEING,
	SEEKING_BUFF
}

var velocity : float = 15.0
var direction : int = 1
var maxLife: float = 100.0
var currentLife: float = 0.0
signal destruct_ball
var player : Node2D

signal entered_zone(zone)  
signal exited_zone(zone)   
signal entered_power_up(power_up)
var attackDistance : float = 5.0  # Distância de ataque do inimigo

var hpBar : ColorRect
var lifeBar : ColorRect

var currentState: State = State.NORMAL

func _ready():
	connect("area_entered", Callable(self, "_on_bullet_body_entered"))
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_exited", Callable(self, "_on_area_exited"))
	player = get_node("/root/Node2D/player")
	currentLife = maxLife
	
	hpBar = $Hp  
	lifeBar = hpBar.get_node("Bar")

func move(delta):
	update_life_bar()
	make_decision(delta)

func _on_bullet_body_entered(body):
	if body.is_in_group("bullets"):
		body.queue_free()
		currentLife -= 30
		if currentLife <= 0:
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

func _on_powerUp_entered(area: Area2D):
	if area.is_in_group("powerups"):  # Verifica se é um power-up
		emit_signal("entered_power_up", self, area)

func update_life_bar():
	if lifeBar:
		var life_percentage = currentLife / maxLife
		lifeBar.size.x = hpBar.size.x * life_percentage

# A árvore de decisões que determina o estado do inimigo
func make_decision(delta):
	# Verificando as condições para a árvore de decisões
	if should_attack():
		currentState = State.ATTACKING
		print("Atacando o jogador")
	elif should_flee():
		currentState = State.FLEEING
		print("Estado de fuga")
	elif should_seek_buff():
		currentState = State.SEEKING_BUFF
		print("Buscando power-up")
	else:
		currentState = State.NORMAL
		print("Estado normal")

	# Movimenta de acordo com o estado atual
	match currentState:
		State.ATTACKING:  # Se o inimigo estiver atacando
			attack_player()
		State.NORMAL:
			move_towards_player(delta)
		State.FLEEING:
			move_away_from_player(delta)
		State.SEEKING_BUFF:
			move_towards_buff(delta)

# Função que verifica se o inimigo deve atacar
func should_attack() -> bool:
	var distance_to_player = position.distance_to(player.position)
	if distance_to_player <= attackDistance:  # Se o inimigo estiver dentro da distância de ataque
		return true
	return false

# Função que verifica se o inimigo deve fugir
func should_flee() -> bool:
	if currentLife <= (maxLife * 0.3):  # Se a vida for menor que 30%
		return true
	var distance_to_player = position.distance_to(player.position)
	return false

# Função que verifica se o inimigo deve procurar um buff
func should_seek_buff() -> bool:
	var distance_to_player = position.distance_to(player.position)
	if distance_to_player >= 200:  # Se o inimigo estiver longe do jogador
		var nearest_buff = find_nearest_buff()
		if nearest_buff:
			return true  # Se existir um buff dentro de um raio
	return false

# Encontrar o buff mais próximo
func find_nearest_buff():
	var max_search_distance = 500
	var buffs = get_tree().get_nodes_in_group("powerups")
	var nearest_buff = null
	var min_distance = max_search_distance
	for buff in buffs:
		var distance = global_position.distance_to(buff.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_buff = buff
	return nearest_buff

# Move o inimigo para longe do jogador (fuga)
func move_away_from_player(delta):
	var distance_to_player = position.distance_to(player.position)
	if distance_to_player < 200:  # Distância de fuga
		var direction = (position - player.position).normalized()  # Direção para longe do jogador
		position += direction * velocity * delta  # Move o inimigo para longe
	else:
		print("Distância de fuga alcançada, parado.")

# Move o inimigo em direção ao jogador
func move_towards_player(delta):
	var direction = (player.position - position).normalized()  # Calcula a direção para o jogador
	position += direction * velocity * delta  # Move a bola na direção do jogador com base na velocidade

# Move o inimigo em direção ao buff
func move_towards_buff(delta):
	var target_buff = find_nearest_buff()
	if target_buff:
		var direction = (target_buff.global_position - global_position).normalized()
		position += direction * velocity * delta
	else:
		print("Nenhum buff disponível, retornando ao estado normal.")
		currentState = State.NORMAL

# Função para restaurar vida
func restore_life(amount):
	currentLife += amount
	if currentLife > maxLife:
		currentLife = maxLife
	print("Vida restaurada para: ", currentLife)

# Função para atacar o jogador
func attack_player():
	print("Inimigo atacando o jogador!")
