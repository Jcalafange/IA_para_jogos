extends CharacterBody2D

@export var speed: float = 200.0  # Velocidade da bola
signal entered_zone(zone)
signal exited_zone(zone)

func _physics_process(delta: float) -> void:
	# Reseta a velocidade do corpo a cada frame
	velocity = Vector2.ZERO

	# Movimento básico usando setas do teclado ou WASD
	if Input.is_action_pressed("move_right"):
		velocity.x += speed
	elif Input.is_action_pressed("move_left"):
		velocity.x -= speed
	if Input.is_action_pressed("move_down"):
		velocity.y += speed
	elif Input.is_action_pressed("move_up"):
		velocity.y -= speed

	# Move a bola usando move_and_slide()
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed  # Normaliza para manter velocidade constante
	move_and_slide()

	# Checa colisão com zonas
	check_zone_collision()

func check_zone_collision() -> void:
	for zone in get_tree().get_nodes_in_group("zones"):
		if zone.has_node("CollisionShape2D"):
			var collision_shape = zone.get_node("CollisionShape2D") as CollisionShape2D
			if collision_shape and collision_shape.shape is RectangleShape2D:
				var rect_size = collision_shape.shape.extents * 2  # Extensões para obter o tamanho total do retângulo
				var zone_position = zone.global_position

				# Verifica se a posição da bola está dentro dos limites do retângulo
				if self.global_position.x > zone_position.x - rect_size.x / 2 and \
					self.global_position.x < zone_position.x + rect_size.x / 2 and \
					self.global_position.y > zone_position.y - rect_size.y / 2 and \
					self.global_position.y < zone_position.y + rect_size.y / 2:
					zone.set_active(true)
					GameController.toggle_zone(zone)
				else:
					zone.set_active(false)
					GameController.toggle_zone(zone)
		else:
			print("Aviso: Zona '%s' não possui um CollisionShape2D." % zone.name)
