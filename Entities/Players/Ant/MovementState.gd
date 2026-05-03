extends StateNode
class_name MovementState

func physics_update(delta: float) -> void:
	var player: Player2D = actor as Player2D

	handle_jump(player)
	player.handle_movement()

	if player.can_wall_slide():
		state_machine.change_state("WallSlide")
	
	player.apply_gravity(delta)

func handle_input(event: InputEvent) -> void:
	if actor is Player2D:
		if event.is_action_pressed("ui_accept"):
			actor.jump_buffer_timer = 6
		
		elif event.is_action_pressed("Dash") and actor.can_dash and actor.dash_cooldown:
			actor.start_dash()

func handle_jump(player: Player2D)-> void:
	if player.jump_buffer_timer > 0 and (player.is_on_floor() or player.coyote_timer > 0):
		player.velocity.y = -player.jump_velocity
		player.coyote_timer = 0
		player.jump_buffer_timer = 0
		player.audio_movements.volume_0_100 = 40
		player.audio_movements.play_stream(Player2D.audio_jump)
