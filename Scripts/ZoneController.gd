extends ColorRect

var original_color: Color
var target_color: Color = Color(0, 1, 0)  # Cor alvo (ex: vermelho)

func _ready():
	original_color = modulate  # Armazena a cor original

func update_color(delta: float, speed: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0  # Converte milissegundos para segundos
	var t = sin(time * speed) * 0.5 + 0.5  # Normaliza t entre 0 e 1
	modulate = original_color.lerp(target_color, t)  # Usando lerp
