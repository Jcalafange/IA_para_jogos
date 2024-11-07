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

func _on_spawn_power_up_timer_timeout():
	var random_position = Vector2(randf() * 800, randf() * 600)  # Define uma posição aleatória
	spawn_power_up(random_position)
	
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

func spawn_power_up(position: Vector2):
	var power_up_scene = preload("res://scenes/PowerUp/PowerUp.tscn")  # Caminho para a cena do power-up
	var power_up_instance = power_up_scene.instantiate()  # Instancia o power-up
	add_child(power_up_instance)
	power_up_instance.position = position  # Define a posição do power-up

	# Conecta o power-up ao jogador
	var player = get_tree().get_nodes_in_group("Player")[0]  # Supondo que o jogador está no grupo "Player"
	player.connect_power_up(power_up_instance)

func _on_player_status_change(currentLife):
	hpBar.size.x = (currentLife/100.0) * hpBar.size.x # Replace with function body.
