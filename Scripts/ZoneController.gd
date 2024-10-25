extends Area2D  # Agora herda de Area2D, e não mais de ColorRect

var original_color: Color

var target_color: Color = Color(0, 1, 0)  # Cor alvo (ex: vermelho)
var balls_in_zone = []
signal ball_entered_zone(ball, zone)
signal ball_exited_zone(ball, zone)

func _ready():
	original_color = modulate  # Armazena a cor original
	add_to_group("Zonas")  # Adiciona a zona ao grupo "Zonas"
	connect("body_entered", Callable(self, "_on_body_entered"))  # Usando Callable
	connect("body_exited", Callable(self, "_on_body_exited"))  # Usando Callable

func _on_body_entered(body):
	if body is CharacterBody2D:
		print("A bola entrou na zona: ", self.name)  # Se a bola (jogador) entrou na zona
		GameController.toggle_zone(self)
		#set_active(true)

func _on_body_exited(body):
	if body is CharacterBody2D:
		print("A bola saiu da zona: ", self.name)  # Se a bola (jogador) saiu da zona
		GameController.toggle_zone(self)
		#set_active(false)

func update_color(delta: float, speed: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0  # Converte milissegundos para segundos
	var t = sin(time * speed) * 0.5 + 0.5  # Normaliza t entre 0 e 1
	modulate = original_color.lerp(target_color, t)  # Usando lerp

func is_inside_zone(area: Area2D) -> bool:
	var position = area.global_position
	var collision_shape = $CollisionShape2D.shape # Certifique-se de que o nó existe
	var zone_size = Vector2(collision_shape.extents.x * 2, collision_shape.extents.y * 2)
	
	return position.x >= self.position.x and position.x <= self.position.x + zone_size.x and position.y >= self.position.y and position.y <= self.position.y + zone_size.y

func move_balls() -> void:
	for ball in balls_in_zone:
		ball.move((self.position.x + 25), (self.position.x + 275))
