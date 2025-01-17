extends Node2D

@onready var bullet_scene = preload("res://scenes/Bullet/bullet.tscn")

func _on_player_shoot(pos, dir):
	print("Bullet Manager Aqui")
	var bullet = bullet_scene.instantiate()
	bullet.creator = 'player'
	bullet.position = pos
	bullet.direction = dir.normalized()
	bullet.rotation = dir.angle() + PI / 2
	bullet.add_to_group('bullets')
	get_parent().add_child(bullet)
	print("Bala criada em:", pos)

func _on_enemy_shoot(pos, dir):
	var bullet = bullet_scene.instantiate()
	bullet.creator = 'enemy'
	bullet.position = pos
	bullet.direction = dir.normalized()
	bullet.rotation = dir.angle() + PI / 2
	bullet.add_to_group('Enemybullets')
	get_parent().add_child(bullet)
	print("Inimigo Atirou")
