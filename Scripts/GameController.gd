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

func add_ball_to_zone(zone: Area2D, ball: ballController) -> void:
	# Adiciona a bola à lista de bolas da zona
	if zone is ZonaController:
		zone.balls_in_zone.append(ball)
		print("Bola adicionada à zona: ", zone.name)

# Função chamada quando uma bola entra em uma zona
func _on_ball_entered_zone(zone: ZonaController, ball: ballController) -> void:
	# Adiciona a bola à zona ativa
	if zone not in active_zones:
		#active_zones.append(zone)
		zone.balls_in_zone.append(ball)  # Adiciona a bola à zona
		print("Bola entrou na zona: ", zone.name)

func remove_ball_from_zone(zone: Area2D, ball: ballController) -> void:
	# Remove a bola da lista de bolas da zona
	if zone is ZonaController:
		zone.balls_in_zone.erase(ball)
		print("Bola removida da zona: ", zone.name)
