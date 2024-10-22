extends ColorRect

var original_color: Color
var target_color: Color = Color(0, 1, 0)  # Cor alvo (ex: vermelho)
var balls_in_zone = []

func _ready():
	original_color = modulate  # Armazena a cor original

func update_color(delta: float, speed: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0  # Converte milissegundos para segundos
	var t = sin(time * speed) * 0.5 + 0.5  # Normaliza t entre 0 e 1
	modulate = original_color.lerp(target_color, t)  # Usando lerp

func is_inside_zone(position: Vector2) -> bool:
	return position.x >= self.position.x and position.x <= self.position.x + self.size.x and position.y >= self.position.y and position.y <= self.position.y + self.size.y

func move_balls() -> void:
	for ball in balls_in_zone:
		ball.move((self.position.x + 25), (self.position.x + 275))
