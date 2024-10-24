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
		#set_active(true)

func _on_body_exited(body):
	if body is CharacterBody2D:
		print("A bola saiu da zona: ", self.name)  # Se a bola (jogador) saiu da zona
		#set_active(false)

func update_color(delta: float, speed: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0  # Converte milissegundos para segundos
	var t = sin(time * speed) * 0.5 + 0.5  # Normaliza t entre 0 e 1
	modulate = original_color.lerp(target_color, t)  # Usando lerp

func is_inside_zone(position: Vector2) -> bool:
	return position.x >= self.position.x and position.x <= self.position.x + self.size.x and position.y >= self.position.y and position.y <= self.position.y + self.size.y

func _on_Zone_area_entered(area):
	if area.is_in_group("Balls"):  # Verifica se o objeto que entrou é uma bola
		balls_in_zone.append(area)
		print("Bola entrou na zona: ", area)

func _on_Zone_area_exited(area):
	if area.is_in_group("Balls"):  # Verifica se o objeto que saiu é uma bola
		balls_in_zone.erase(area)
		print("Bola saiu da zona: ", area)

func move_balls() -> void:
	for ball in balls_in_zone:
		ball.move((self.position.x + 25), (self.position.x + 275))
