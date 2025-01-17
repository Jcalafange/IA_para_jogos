extends CharacterBody2D

class_name enemyController

enum EnemyType {
	MELEE,
	RANGED
}

enum State {
	NORMAL,
	ATTACKING,
	FLEEING,
	AVOID,
	SEEKING_BUFF
}

@export var enemy_type: EnemyType = EnemyType.MELEE  # Tipo do inimigo
@export var shooting_distance: float = 100.0  # Distância para disparar (apenas para RANGED)
@export var attackDistance: float = 5.0
@export var maxLife: float = 100.0
@export var speed: float = 25.0

var currentLife: float = maxLife
var currentState: State = State.NORMAL
var can_shoot: bool = true
var avoid_timer_active: bool = false

@onready var player = $"../player"
@onready var hpBar = $Hp
@onready var lifeBar = $Hp/Bar

@onready var bullet_scene = preload("res://scenes/Bullet/bullet.tscn")

@onready var evasion_area = $Evasion
@onready var evasion_shape = $Evasion/Collision
@onready var evasion_timer = $AvoidTimer
var bullet_position: Vector2
var bullet_velocity: Vector2

@onready var rangedTexture = preload("res://sprints/path2.png")

signal destruct_enemy
signal entered_zone(zone)
signal exited_zone(zone)
signal shoot

func _ready():
	if enemy_type == EnemyType.RANGED:
		bullet_scene = preload("res://scenes/Bullet/bullet.tscn")  # Carrega a cena da bala
		$Sprite2D.texture = rangedTexture
		
	
	evasion_area.connect("area_entered", Callable(self, "on_evasion_area_entered"))
	evasion_timer.connect("timeout", Callable(self, "on_avoid_timeout"))

func update_life_bar():
	if lifeBar:
		var life_percentage = currentLife / maxLife
		lifeBar.size.x = hpBar.size.x * life_percentage

func takeDamage(damage):
	if currentLife > 0:
		currentLife -= damage
		print(currentLife)
		update_life_bar()
	elif currentLife <= 0:
		print(currentLife)
		queue_free()
	

func make_decision(delta):
	if should_attack():
		currentState = State.ATTACKING
	elif should_flee():
		currentState = State.FLEEING
	#elif should_seek_buff():
		#currentState = State.SEEKING_BUFF
	elif currentState == State.AVOID:  # Se o inimigo está no estado de evasão, faz desvio
		avoid_bullet(delta)
	else:
		currentState = State.NORMAL
	match currentState:
		State.ATTACKING:
			attack_player()
		State.NORMAL:
			move_towards_player(delta)
		#State.FLEEING:
			#move_away_from_player(delta)
		State.AVOID:
			avoid_bullet(delta)  # Evasão durante o estado de desvio
		#State.SEEKING_BUFF:
			#move_towards_buff(delta)

func move_towards_player(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed

func move(delta):
	make_decision(delta)
	move_and_slide()

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


#func should_seek_buff() -> bool:
#	if position.distance_to(player.position) >= 200:
#		var nearest_buff = find_nearest_buff()
#		if nearest_buff:
#			return true
#	return false

func on_evasion_area_entered(area: Area2D):
	if area.is_in_group("bullets") and not avoid_timer_active:
		print("Desviar da bala")
		bullet_position = area.global_position
		bullet_velocity = area.get("direction") * area.get("speed")
		currentState = State.AVOID
		evasion_timer.start()  # Inicia o timer de desvio
		avoid_timer_active = true

func avoid_bullet(delta):
	# Previsão da posição da bala
	var prediction_time = position.distance_to(bullet_position) / bullet_velocity.length()
	var predicted_bullet_position = bullet_position + bullet_velocity * prediction_time

	# Direção para o jogador
	var direction_to_player = (player.global_position - global_position).normalized()

	# Direção para desviar da bala
	var direction_to_bullet = (global_position - predicted_bullet_position).normalized()

	# Determina o lado do desvio (direita ou esquerda)
	var cross_product = direction_to_player.cross(direction_to_bullet)
	var lateral_direction = 1 if cross_product > 0 else -1

	# Calcula o ângulo de desvio (45 graus, ajustável)
	var angle_offset = deg_to_rad(45) * lateral_direction

	# Aplica a rotação para calcular a direção de desvio
	var final_direction = direction_to_player.rotated(angle_offset).normalized()

	# Aplica o movimento com a direção final calculada
	velocity = final_direction * speed
	move_and_slide()

func on_avoid_timeout():
	print("Fim do desvio")
	currentState = State.NORMAL  # Retorna ao estado normal
	avoid_timer_active = false


func _on_bullet_area_entered(area: Area2D) -> void:
	print("Colidiu com uma bullet")
	if area.is_in_group("bullets"):
		# A bullet foi detectada entrando na área do inimigo
		print("Colidiu com uma bullet") # Replace with function body.

func get_predicted_player_position(delta: float) -> Vector2:
	if not player or not player.has_method("get_velocity"):
		return player.position  # Retorna a posição atual se não houver previsão possível
	var player_velocity: Vector2 = player.get_velocity()
	return player.position + player_velocity * delta

func attack_player():
	var target_position = get_predicted_player_position(get_process_delta_time())
	if enemy_type == EnemyType.MELEE:
		move_towards_player(get_process_delta_time())
	elif enemy_type == EnemyType.RANGED and can_shoot:
		print("Inimigo quer disparar")
		shoot_at_position(target_position)

func shoot_at_position(target_position: Vector2):
	print("Inimigo vai disparar")
	var dir = (target_position - global_position).normalized()
	var shooter_size = $Sprite2D.texture.get_size() 
	var shoot_position = global_position + (dir * shooter_size.length())
	shoot.emit(shoot_position, dir)
	can_shoot = false
	$ShootTimer.start()
