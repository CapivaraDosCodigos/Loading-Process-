extends StateNode
class_name WallJumpState

func physics_update(delta: float) -> void:
	var player: Player2D = actor as Player2D
	
	player.handle_movement()
	player.apply_gravity(delta)
	
	if player.can_wall_slide():
		state_machine.change_state("WallSlide")

	elif player.is_on_floor():
		state_machine.change_state("Movement")

func handle_input(event: InputEvent) -> void:
	if actor is Player2D:
		if event.is_action_pressed("ui_accept"):
			actor.jump_buffer_timer = 6
		
		elif event.is_action_pressed("Dash") and actor.can_dash and actor.dash_cooldown:
			actor.start_dash()
