extends Node

@export var all_zones: Array = []
@export var active_zones: Array = []
var all_enemys: Array = []

func _ready() -> void:
	all_zones = get_tree().get_nodes_in_group("Zonas")
	all_enemys = get_tree().get_nodes_in_group("Enemys")
	distribute_enemies()

func _process(delta):
	for zone in active_zones:
		zone.move_enemys(delta)
	
func toggle_zone(zone: Area2D):
	if zone in active_zones:
		active_zones.erase(zone)
		zone.get_node("ColorRect").modulate = Color(1, 1, 1)  # Desativar (cor branca)
	else:
		active_zones.append(zone)
		zone.get_node("ColorRect").modulate = Color(0, 1, 0)

# Função chamada quando o jogador entra em uma zona
func _on_player_entered_zone(zone: Area2D):
	if zone not in active_zones:
		active_zones.append(zone)
		zone.get_node("ColorRect").modulate = Color(0, 1, 0)  # Ativar visualmente (cor verde)
		print("Jogador entrou na zona:", zone.name)

# Função chamada quando o jogador sai de uma zona
func _on_player_exited_zone(zone: Area2D):
	if zone in active_zones:
		active_zones.erase(zone)
		zone.get_node("ColorRect").modulate = Color(1, 1, 1)  # Desativar visualmente (cor branca)
		print("Jogador saiu da zona:", zone.name)

# Distribui inimigos pelas zonas
func distribute_enemies():
	for zone in all_zones:
		#zone.enemies_in_zone = []  # Garante que a lista esteja limpa
		for enemy in all_enemys:
			if zone.is_inside_zone(enemy) and (enemy not in zone.enemys_in_zone):
				zone.enemys_in_zone.append(enemy)
