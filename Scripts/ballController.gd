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
	SEEKING_BUFF
}

@export var enemy_type: EnemyType = EnemyType.MELEE  # Tipo do inimigo
@export var shooting_distance: float = 100.0  # Distância para disparar (apenas para RANGED)
@export var velocity: float = 15.0
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

func _ready():
	connect("area_entered", Callable(self, "_on_bullet_body_entered"))
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_exited", Callable(self, "_on_area_exited"))
	
	player = get_node("/root/Node2D/player")
	currentLife = maxLife
	hpBar = $Hp
	lifeBar = hpBar.get_node("Bar")
	
	if player.has_method("get_velocity"):
		predicted_player_position = player.position  # Inicialização

	if enemy_type == EnemyType.RANGED:
		bullet_scene = preload("res://scenes/Bullet/bullet.tscn")  # Carrega a cena da bala

func move(delta):
	update_life_bar()
	make_decision(delta)

func _on_bullet_body_entered(body):
	if body.is_in_group("bullets"):
		if body.has_method("get_creator") and body.get_creator() == "player":
			# Executa a lógica apenas se a bala foi criada pelo jogador
			body.queue_free()
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
	else:
		currentState = State.NORMAL

	match currentState:
		State.ATTACKING:
			attack_player()
		State.NORMAL:
			move_towards_player(delta)
		State.FLEEING:
			move_away_from_player(delta)
		State.SEEKING_BUFF:
			move_towards_buff(delta)

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
	bullet.add_to_group("bullets")
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
