extends Node

@export var all_zones: Array = []
@export var active_zones: Array = []
@export var current_zone_index: int = 0
var all_balls: Array = []

func _ready() -> void:
	all_zones = get_tree().get_nodes_in_group("Zonas")
	all_balls = get_tree().get_nodes_in_group("Balls")
	set_process_input(true)
	for ball in all_balls:
		for zone in all_zones:
			if(ball.position.x > zone.position.x and ball.position.x < (zone.position.x + zone.size.x) and ball.position.y > zone.position.y and ball.position.y < (zone.position.y + zone.size.y)):
				zone.balls_in_zone.append(ball)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		for zone in all_zones:
			if zone.is_inside_zone(get_viewport().get_mouse_position()):
				toggle_zone(zone)

# Função para ativar/desativar zonas
func toggle_zone(zone: ColorRect):
	if zone in active_zones:
		active_zones.erase(zone)
		zone.modulate = Color(1, 1, 1)
	else:
		active_zones.append(zone)
		zone.modulate = Color(0, 1, 0) # Verde para zona ativa

# Atualiza as zonas ativas e suas bolas
func _process(delta):
	for zone in active_zones:
		zone.update_color(delta, 5)
		zone.move_balls()
