extends StateNode
class_name DashState

func physics_update(_delta: float) -> void:
	var player: Player2D = actor as Player2D
	
	player.velocity.x = (player.dash_distance / player.dash_duration) * player.direction
	player.velocity.y = 0.0

	if player.dash_ghost_timer == 0:
		player.create_ghost_sprite()
		player.dash_ghost_timer = 3
