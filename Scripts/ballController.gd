extends Area2D

class_name ballController

# Enum para os tipos de inimigos
enum EnemyType {
	MELEE,
	RANGED
}

# Estado do inimigo
enum State {
	NORMAL,
	ATTACKING,
	FLEEING,
	AVOID,
	SEEKING_BUFF
}

@export var enemy_type: EnemyType = EnemyType.MELEE  # Tipo do inimigo
@export var shooting_distance: float = 100.0  # Distância para disparar (apenas para RANGED)
@export var avoidance_radius: float = 50.0
@export var velocity: float = 25.0
@export var attackDistance: float = 5.0  # Distância de ataque corpo a corpo
@export var maxLife: float = 100.0

var currentLife: float = maxLife
var currentState: State = State.NORMAL
var bullet_scene: PackedScene
var can_shoot: bool = true

signal destruct_ball
signal entered_zone(zone)
signal exited_zone(zone)
signal entered_power_up(power_up)

var player: Node2D
var hpBar: ColorRect
var lifeBar: ColorRect
var predicted_player_position: Vector2 = Vector2()

# Variáveis para lidar com a detecção de balas
var evasion_area: Area2D
var evasion_shape: CollisionShape2D
var bullet_position: Vector2
var bullet_velocity: Vector2

func _ready():
	connect("area_entered", Callable(self, "_on_bullet_body_entered"))
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_exited", Callable(self, "_on_area_exited"))
	
	var rangedTexture = load("res://sprints/path2.png")
	
	player = get_node("/root/Node2D/player")
	currentLife = maxLife
	hpBar = $Hp
	lifeBar = hpBar.get_node("Bar")
	
	if player.has_method("get_velocity"):
		predicted_player_position = player.position  # Inicialização

	if enemy_type == EnemyType.RANGED:
		bullet_scene = preload("res://scenes/Bullet/bullet.tscn")  # Carrega a cena da bala
		$Sprite2D.texture = rangedTexture
	
	# Referência para o nó Evasion
	evasion_area = $Evasion
	evasion_shape = evasion_area.get_node("CollisionShape2D")
	evasion_area.connect("area_entered", Callable(self, "on_evasion_area_entered"))
	evasion_area.connect("area_exited", Callable(self, "on_evasion_area_exited"))

func move(delta):
	update_life_bar()
	make_decision(delta)

func _on_bullet_body_entered(body):
	if body.is_in_group("bullets"):
		# Verifica se a bala foi disparada pelo jogador
		if body.has_method("get_creator") and body.get_creator() == "player":
			body.queue_free()  # Destroi a bala
			currentLife -= 30
			if currentLife <= 0:
				emit_signal("destruct_ball", self)
				queue_free()

func _on_area_entered(area: ZoneController):
	if area is ZoneController:
		emit_signal("entered_zone", area, self)

func _on_area_exited(area: ZoneController):
	if area is ZoneController:
		emit_signal("exited_zone", area, self)

func get_predicted_player_position(delta: float) -> Vector2:
	if not player or not player.has_method("get_velocity"):
		return player.position  # Retorna a posição atual se não houver previsão possível

	var player_velocity: Vector2 = player.get_velocity()
	return player.position + player_velocity * delta

# Detecção de balas e mudança para o estado de evasão
func on_evasion_area_entered(area: Area2D):
	if area.is_in_group("bullets"):
		# Obtemos a posição e direção da bala
		bullet_position = area.global_position
		bullet_velocity = area.get("direction") * area.get("speed")  # Direção e velocidade da bala
		currentState = State.AVOID  # Entra no estado de evasão

func on_evasion_area_exited(area: Area2D):
	if area.is_in_group("bullets"):  # A bala saiu da zona de evasão, o inimigo pode retomar a perseguição
		currentState = State.NORMAL

# Comportamento de desvio (evitar a bala)
func avoid_bullet(delta):
	print("Desviar com 45 graus")
	
	# Previsão de onde a bala estará dentro de um intervalo de tempo
	var prediction_time = position.distance_to(bullet_position) / bullet_velocity.length()
	var predicted_bullet_position = bullet_position + bullet_velocity * prediction_time
	
	# Calcula a direção para perseguir o jogador
	var direction_to_player = (player.position - position).normalized()  # Direção do inimigo para o jogador
	
	# Calcula a direção do desvio lateral em relação à bala
	var direction_to_bullet = (position - predicted_bullet_position).normalized()  # Direção para desviar da bala

	# Determina se o inimigo vai desviar para a esquerda ou para a direita
	var cross_product = direction_to_player.x * direction_to_bullet.y - direction_to_player.y * direction_to_bullet.x
	var lateral_direction = 0  # 1 para direita, -1 para esquerda
	
	# Definir o desvio lateral dependendo do lado onde a bala vem
	if cross_product > 0:
		lateral_direction = 1  # Desviar para a direita
	elif cross_product < 0:
		lateral_direction = -1  # Desviar para a esquerda
	
	# Ângulo do desvio de 45 graus em radianos
	var angle_offset = deg_to_rad(90) * lateral_direction
	
	# Calcula a direção final do movimento do inimigo, aplicando o desvio
	var final_direction = direction_to_player.rotated(angle_offset)  # Rotaciona a direção do inimigo em 45 graus
	final_direction = final_direction.normalized()  # Garante que a direção seja normalizada
	
	# Movimento suave do inimigo, mantendo a perseguição ao jogador, mas com o desvio aplicado
	position += final_direction * (velocity + 50) * delta

func update_life_bar():
	if lifeBar:
		var life_percentage = currentLife / maxLife
		lifeBar.size.x = hpBar.size.x * life_percentage

func make_decision(delta):
	if should_attack():
		currentState = State.ATTACKING
	elif should_flee():
		currentState = State.FLEEING
	elif should_seek_buff():
		currentState = State.SEEKING_BUFF
	elif currentState == State.AVOID:  # Se o inimigo está no estado de evasão, faz desvio
		avoid_bullet(delta)
	else:
		currentState = State.NORMAL

	match currentState:
		State.ATTACKING:
			attack_player()
		State.NORMAL:
			move_towards_player(delta)
		State.FLEEING:
			move_away_from_player(delta)
		State.AVOID:
			avoid_bullet(delta)  # Evasão durante o estado de desvio
		State.SEEKING_BUFF:
			move_towards_buff(delta)

# Funções auxiliares
func should_attack() -> bool:
	var distance_to_player = position.distance_to(player.position)
	if enemy_type == EnemyType.MELEE and distance_to_player <= attackDistance:
		return true
	elif enemy_type == EnemyType.RANGED and distance_to_player <= shooting_distance:
		return true
	return false

func should_flee() -> bool:
	if currentLife <= (maxLife * 0.3):
		return true
	return false

func should_seek_buff() -> bool:
	if position.distance_to(player.position) >= 200:
		var nearest_buff = find_nearest_buff()
		if nearest_buff:
			return true
	return false

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

func attack_player():
	var target_position = get_predicted_player_position(get_process_delta_time())
	if enemy_type == EnemyType.MELEE:
		move_towards_player(get_process_delta_time())
	elif enemy_type == EnemyType.RANGED and can_shoot:
		shoot_at_position(target_position)

func shoot_at_position(target_position: Vector2):
	if not bullet_scene:
		print("Cena da bala não configurada!")
		return
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	var direction = (target_position - global_position).normalized()
	bullet.direction = direction
	bullet.rotation = direction.angle() + PI / 2
	bullet.creator = 'enemy'
	bullet.add_to_group("Enemybullets")
	can_shoot = false
	$ShootTimer.start()

func _on_shoot_timer_timeout():
	can_shoot = true

func move_away_from_player(delta):
	var target_position = get_predicted_player_position(delta)
	var direction = (position - target_position).normalized()
	position += direction * velocity * delta

func move_towards_player(delta):
	var target_position = get_predicted_player_position(delta)
	var direction = (target_position - position).normalized()
	position += direction * velocity * delta

func move_towards_buff(delta):
	var target_buff = find_nearest_buff()
	if target_buff:
		var direction = (target_buff.global_position - global_position).normalized()
		position += direction * velocity * delta
	else:
		currentState = State.NORMAL

func restore_life(amount):
	currentLife += amount
	if currentLife > maxLife:
		currentLife = maxLife
