extends StateNode
#class_name WallJumpState

func physics_update(delta: float) -> void:
	var player: Player2D = actor as Player2D
	
	player.handle_movement()
	
	player.apply_gravity(delta)
	
	if handle_dash(player):
		return
	
	elif player.can_wall_slide():
		state_machine.change_state("WallSlide")

	elif player.is_on_floor():
		state_machine.change_state("Movement")

func handle_dash(player: Player2D)-> bool:
	if player.buffer_dash.is_interval() and player.can_dash and player.dash_cooldown:
		if player.has_dash:
			player.direction = player.wall_direction
			player.animation.scale.x = player.direction
			player.animation.play("Jump")
			state_machine.change_state("Dash")
			
			return true
			
		player.buffer_dash.set_buffer_time()
		player.use_skills()
		
	return false
