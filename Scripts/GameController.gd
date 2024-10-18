extends Node

@export var all_zones: Array = []
@export var active_zones: Array = []
@export var current_zone_index: int = 0
@export var timer: float = 0.0
const SWITCH_INTERVAL: float = 30.0  # Intervalo de troca em segundos

func _ready() -> void:
	all_zones = get_children()
	if all_zones.size() > 0:
		active_zones.append(all_zones.front())  # Adiciona a primeira zona ativa

func _process(delta: float) -> void:
	# Atualiza a cor das zonas ativas
	for zone in active_zones:
		if zone.has_method("update_color"):
			zone.update_color(delta, 1.0)  # Chama a função de mudança de cor


func switch_zone() -> void:
	if active_zones.size() > 0:
		active_zones.pop_front()  # Remove a zona ativa atual

	current_zone_index += 1  # Avança para a próxima zona
	if current_zone_index >= all_zones.size():
		current_zone_index = 0  # Reseta para a primeira zona

	active_zones.append(all_zones[current_zone_index])  # Adiciona a próxima zona
