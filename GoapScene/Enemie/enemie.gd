extends CharacterBody2D

var is_moving = false
var is_attacking = false

var maxLife = 100
var currentLife = 0
var lifeBar = ColorRect
var hpBar = ColorRect
var chase_speed = 100

func _ready():
	hpBar = $MaxLife
	lifeBar = $MaxLife/CurrentLife
	currentLife = maxLife
	var agent = GoapAgent.new()
	agent.init(self, [ChasePlayerGoal.new(), StayGoal.new(), HealGoal.new()])
	add_child(agent)

func move_to(direction, delta):
	is_moving = true
	is_attacking = false
	velocity = direction * 100  # Ajuste para uma velocidade apropriada.
	move_and_slide()

func regenerate_health(regen: int):
	if currentLife < maxLife:
		currentLife += regen
	WorldState.set_state("enemie_life", currentLife)
	update_life_bar()

func takeDamage(damage: int):
	if currentLife > 0:
		currentLife -= damage
	WorldState.set_state("enemie_life", currentLife)
	update_life_bar()

func update_life_bar():
	if lifeBar:
		var life_percentage = currentLife / maxLife
		lifeBar.size.x = hpBar.size.x * life_percentage
	if currentLife < 50:
		WorldState.set_state("enemy_need_heal", true)
	elif currentLife > 50 and currentLife < 70:
		WorldState.set_state("enemy_need_heal", false)
	print(WorldState.get_state("enemy_need_heal"))

func _on_hit_box_body_entered(body: Node2D) -> void:
	print("Hit")
	print(body.get_groups())
	if body.is_in_group("Player"):
		print("Player Detected")
		body.currentLife -= 10  # Subtrai 10 da vida do jogador quando ele entra na caixa de colisão
		print("Player hit! Current life: %s" % body.currentLife)
		if body.currentLife <= 0:
			WorldState.set_state("player_dead", true)
			print("Player is dead!") #function body.
		var push_direction = (position - body.position).normalized()  # Direção oposta ao jogador
		var push_strength = 50  # Força do empurrão (ajuste conforme necessário)
		
		# Movimenta o inimigo para trás (deslocamento)
		position += push_direction * push_strength
		
	

func _on_hit_box_area_entered(area: Area2D) -> void:
	print("Acertou")
	if area.is_in_group("bullets"):
		print("Bala atingiu")
		# Verifica se a bala foi disparada pelo jogador
		if area.has_method("get_creator") and area.get_creator() == "player":
			takeDamage(10)
			print(currentLife)
			WorldState.set_state("enemie_life", currentLife)
			area.queue_free()
