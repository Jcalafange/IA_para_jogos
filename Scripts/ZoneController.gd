extends Area2D  # Agora herda de Area2D, e não mais de ColorRect

var original_color: Color
var target_color: Color = Color(0, 1, 0)  # Cor alvo (verde)
var is_active: bool = false

func _ready():
	original_color = modulate  # Armazena a cor original
	add_to_group("zones")  # Adiciona a zona ao grupo "zones"
	connect("body_entered", Callable(self, "_on_body_entered"))  # Usando Callable
	connect("body_exited", Callable(self, "_on_body_exited"))  # Usando Callable

func _on_body_entered(body):
	if body is CharacterBody2D:
		print("A bola entrou na zona: ", self.name)  # Se a bola (jogador) entrou na zona
		set_active(true)

func _on_body_exited(body):
	if body is CharacterBody2D:
		print("A bola saiu da zona: ", self.name)  # Se a bola (jogador) saiu da zona
		set_active(false)

func update_color(delta: float, speed: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0  # Converte milissegundos para segundos
	var t = sin(time * speed) * 0.5 + 0.5  # Normaliza t entre 0 e 1
	modulate = original_color.lerp(target_color, t)  # Usando lerp para suavizar a transição

func set_active(active: bool) -> void:
	is_active = active
	if is_active:
		modulate = target_color  # Muda para a cor alvo
	else:
		modulate = original_color  # Retorna à cor original
