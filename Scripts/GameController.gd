extends Node

@export var all_zones: Array = []
@export var active_zones: Array = []
@export var current_zone_index: int = 0
@export var hpBar: ColorRect
var all_balls: Array = []


func _ready() -> void:
	all_zones = get_tree().get_nodes_in_group("Zonas")
	all_balls = get_tree().get_nodes_in_group("Balls")
	distribuir_balls()
	connect_signals()
	set_process_input(true)
	
	var timer = Timer.new()
	timer.wait_time = 10  # Spawn de power-up a cada 10 segundos
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_on_spawn_power_up_timer_timeout"))
	add_child(timer)
	timer.start()
	
	print_all_zones_and_balls()

func _on_spawn_power_up_timer_timeout():
	var random_position = Vector2(randf() * 800, randf() * 600)  # Define uma posição aleatória

	# Lista de tipos de power-up
	var power_up_types = ["heal", "speed", "speed_atk"]

	# Escolhe um tipo aleatório
	var random_type = power_up_types[randi() % power_up_types.size()]

	# Chama spawn_power_up com o tipo aleatório e posição aleatória
	spawn_power_up(random_type, random_position)

# Função para ativar/desativar zonas
func toggle_zone(zone: Area2D):
	if zone in active_zones:
		active_zones.erase(zone)
		zone.get_node("ColorRect").modulate = Color(1, 1, 1)  # Desativar (cor branca)
	else:
		active_zones.append(zone)
		zone.get_node("ColorRect").modulate = Color(0, 1, 0)  # Ativar (cor verde)

func zone_movement(zone: Area2D):
	toggle_zone(zone)

func distribuir_balls():
	for zone in all_zones:
		for ball in all_balls:
			if (zone.is_inside_zone(ball)):
				zone.balls_in_zone.append(ball)
# Atualiza as zonas ativas e movimenta as bolas
func _process(delta):
	#print(active_zones)
	for zone in active_zones:
		zone.move_balls(delta)  # Função customizada para mover bolas dentro da zona

func _on_ball_destructed(ball: ballController) -> void:
	all_balls.erase(ball)
	for zone in all_zones:
		zone.balls_in_zone.erase(ball)

func connect_signals():
	for ball in all_balls:
		ball.connect("destruct_ball", Callable(self, "_on_ball_destructed"))
		ball.connect("entered_zone", Callable(self, "_on_ball_entered_zone"))
		ball.connect("exited_zone", Callable(self, "remove_ball_from_zone"))

func _on_player_status_change(currentLife):
	hpBar.size.x = (currentLife/100.0) * hpBar.size.x # Replace with function body.

# Função chamada quando uma bola entra em uma zona
func _on_ball_entered_zone(zone: ZoneController, ball: ballController) -> void:
	# Adiciona a bola à zona ativa
	if zone not in active_zones:
		#active_zones.append(zone)
		if ball not in zone.balls_in_zone:
			zone.balls_in_zone.append(ball)  # Adiciona a bola à zona
			print("Bola entrou na zona: ", zone.name)

func remove_ball_from_zone(zone: Area2D, ball: ballController) -> void:
	# Remove a bola da lista de bolas da zona
	if zone is ZoneController:
		zone.balls_in_zone.erase(ball)
		print("Bola removida da zona: ", zone.name)
	#print_all_zones_and_balls()

func spawn_power_up(power_up_type: String, position: Vector2):
	var power_up_scene
	match power_up_type:
		"heal":
			power_up_scene = preload("res://scenes/PowerUP/PowerUpHeal.tscn")
		"speed":
			power_up_scene = preload("res://scenes/PowerUP/PowerUpSpeed.tscn")
		"speed_atk":
			power_up_scene = preload("res://scenes/PowerUP/PowerUpSpeedATK.tscn")
	var power_up_instance = power_up_scene.instantiate()
	add_child(power_up_instance)
	power_up_instance.position = position
	# Conecta o power-up ao jogador
	var player = get_tree().get_nodes_in_group("Player")[0]  # Supondo que o jogador está no grupo "Player"
	#player.connect_power_dsup(power_up_instance)
	match power_up_type:
		"heal":
			player.connect_power_up_heal(power_up_instance)
		"speed":
			player.connect_power_up_speed(power_up_instance)
		"speed_atk":
			player.connect_power_up_speed_atk(power_up_instance)

func print_all_zones_and_balls() -> void:
	for zone in all_zones:
		var ball_names = []
		# Coleta os nomes das bolas dentro da zona
		for ball in zone.balls_in_zone:
			ball_names.append(ball.name)
		# Imprime o nome da zona e suas bolas
		print(zone.name + ": " + str(ball_names))

