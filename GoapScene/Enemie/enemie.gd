extends CharacterBody2D

var is_moving = false
var is_attacking = false

var chase_speed = 100

@onready var player = $"../player"  # Referência ao nó do jogador.

func _ready():
	print("Planejador Preparado")
	var agent = GoapAgent.new()
	agent.init(self, [ChasePlayerGoal.new(), KillPlayerGoal.new()])
	add_child(agent)
	print("Objetivos:")
	for goal in agent._goals:
		print(goal.get_clazz())  # A função get_clazz() retorna o nome do objetivo ou classe
	print("_________")
	#set_process(true)

func followPlayer(delta):
	# Calcula a direção para o jogador
	var direction = (player.position - position).normalized()
	
	# Move o personagem em direção ao jogador
	velocity = direction * chase_speed

	# Atualiza a posição do personagem
	move_and_slide()

func move_to(direction, delta):
	is_moving = true
	is_attacking = false
	velocity = direction * 100  # Ajuste para uma velocidade apropriada.
	move_and_slide()


func _on_hit_box_body_entered(body: Node2D) -> void:
	print("Hit")
	print(body.get_groups())
	if body.is_in_group("Player"):
		print("Player Detected")
		body.currentLife -= 10  # Subtrai 10 da vida do jogador quando ele entra na caixa de colisão
		print("Player hit! Current life: %s" % body.currentLife)
		if body.currentLife <= 0:
			print("Player is dead!") #function body.
		var push_direction = (position - body.position).normalized()  # Direção oposta ao jogador
		var push_strength = 50  # Força do empurrão (ajuste conforme necessário)
		
		# Movimenta o inimigo para trás (deslocamento)
		position += push_direction * push_strength
