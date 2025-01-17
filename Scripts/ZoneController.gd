extends Area2D

class_name ZoneController

var original_color: Color
var target_color: Color = Color(0, 1, 0)  # Cor alvo para indicar estado ativo
var enemys_in_zone = []
signal enemy_entered_zone(enemy, zone)
signal enemy_exited_zone(enemy, zone)

var player: Node2D

func _ready():
	original_color = modulate  # Armazena a cor original
	add_to_group("Zonas")  # Adiciona a zona ao grupo "Zonas"
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

	# Ajuste o caminho do player conforme necessário
	player = get_node("/root/Node2D/player")  # Supondo que "player" seja filho de "Node2D"


func _on_body_entered(body):
	if body.is_in_group("Enemys"):
		if body not in enemys_in_zone:
			enemys_in_zone.append(body)
			emit_signal("enemy_entered_zone", body, self)
			print("Inimigo entrou na zona:", self.name, "Inimigo:", body.name)
	elif body.is_in_group("Player"):
		print(self.name)
		print(enemys_in_zone)
		print("O player entrou na zona:", self.name)
		GameController.toggle_zone(self)

func _on_body_exited(body):
	if body.is_in_group("Enemys"):
		if body in enemys_in_zone:
			enemys_in_zone.erase(body)
			emit_signal("enemy_exited_zone", body, self)
			print("Inimigo saiu da zona:", self.name, "Inimigo:", body.name)
	elif body.is_in_group("Player"):

		print("O player saiu da zona:", self.name)
		GameController.toggle_zone(self)

func update_color(delta: float, speed: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0  # Converte milissegundos para segundos
	var t = sin(time * speed) * 0.5 + 0.5  # Normaliza t entre 0 e 1
	modulate = original_color.lerp(target_color, t)  # Usando lerp

func is_inside_zone(enemy: CharacterBody2D) -> bool:
	var position = enemy.global_position
	var collision_shape = $CollisionShape2D.shape  # Certifique-se de que o nó existe
	var zone_size = Vector2(collision_shape.extents.x * 2, collision_shape.extents.y * 2)

	return position.x >= self.position.x and position.x <= self.position.x + zone_size.x \
		   and position.y >= self.position.y and position.y <= self.position.y + zone_size.y

func move_enemys(delta: float) -> void:
	var bounds = get_zone_bounds()
	for enemy in enemys_in_zone:
		if enemy and is_instance_valid(enemy):
			enemy.move(delta)


func get_zone_bounds() -> Rect2:
	var collision_shape = $CollisionShape2D.shape
	var zone_size = Vector2(collision_shape.extents.x * 2, collision_shape.extents.y * 2)
	var zone_position = position - zone_size / 2
	return Rect2(zone_position, zone_size)
