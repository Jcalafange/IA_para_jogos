extends Node

@export var all_zones: Array = []
@export var active_zones: Array = []
@export var current_zone_index: int = 0
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
		zone.move_balls()  # Função customizada para mover bolas dentro da zona

func _on_ball_destructed(ball: ballController) -> void:
	all_balls.erase(ball)
	for zone in all_zones:
		zone.balls_in_zone.erase(ball)

func connect_signals():
	for ball in all_balls:
		ball.connect("destruct_ball", Callable(self, "_on_ball_destructed"))
