extends StateNode
class_name HurtState

func physics_update(delta: float) -> void:
	var player: Player2D = actor as Player2D

	if player.knockback_vector.x != 0:
		player.velocity.x = player.knockback_vector.x

	if player.knockback_vector.y != 0:
		player.velocity.y = player.knockback_vector.y
	else:
		player.apply_gravity(delta)
