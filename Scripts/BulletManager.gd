extends Node2D

@export var bullet_scene : PackedScene

func _on_player_shoot(pos, dir):
	#print("Player quer disparar")
	var bullet = bullet_scene.instantiate()
	bullet.creator = 'player'
	bullet.position = pos
	#print("Posição do tiro: ", pos)
	bullet.direction = dir.normalized()
	bullet.rotation = dir.angle() + PI / 2
	bullet.add_to_group('bullets')
	add_child(bullet)
