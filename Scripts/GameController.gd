extends Node

@export var all_zones: Array = []
@export var active_zones: Array = []
@export var current_zone_index: int = 0
var all_balls: Array = []

func _ready() -> void:
	all_zones = get_tree().get_nodes_in_group("Zonas")
	all_balls = get_tree().get_nodes_in_group("Balls")
	set_process_input(true)
	# Conecta os sinais de cada zona
		
	set_process_input(true)

# Função para ativar/desativar zonas
func toggle_zone(zone: Area2D):
	if zone in active_zones:
		active_zones.erase(zone)
		zone.get_node("ColorRect").modulate = Color(1, 1, 1)  # Desativar (cor branca)
	else:
		active_zones.append(zone)
		zone.get_node("ColorRect").modulate = Color(0, 1, 0)  # Ativar (cor verde)

# Quando uma bola entra em uma zona
func _on_ball_entered_zone(ball, zone):
	print("Bola entrou na zona: ", ball, " Zona: ", zone)

# Quando uma bola sai de uma zona
func _on_ball_exited_zone(ball, zone):
	print("Bola saiu da zona: ", ball, " Zona: ", zone)

# Atualiza as zonas ativas e movimenta as bolas
func _process(delta):
	for zone in active_zones:
		zone.move_balls()  # Função customizada para mover bolas dentro da zona
