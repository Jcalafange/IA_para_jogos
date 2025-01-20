extends Node2D

@export var bullet_scene : PackedScene

func _on_player_shoot(pos, dir):
	print("Player quer disparar")
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.creator = 'player'
	bullet.position = pos
	bullet.direction = dir.normalized()
	bullet.rotation = dir.angle() + PI / 2
	bullet.add_to_group('bullets')
