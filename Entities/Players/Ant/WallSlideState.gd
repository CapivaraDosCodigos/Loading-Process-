extends StateNode
class_name WallSlideState

func physics_update(delta: float) -> void:
	var player: Player2D = actor as Player2D
	
	if not player.has_wall_slide or player.wall_jump_lock or player.is_on_floor():
		state_machine.change_state("Movement")
		return
	
	player.velocity.y += player.gravity * delta
	
	player.wall_direction = -1.0 if player.ray_right.is_colliding() else 1.0
	
	player.can_dash = true
	
	if player.jump_buffer_timer > 0:
		player.velocity = Vector2(
			player.wall_slide_force * player.wall_direction,
			player.jump_velocity * -1.0
		)
		
		player.coyote_timer = 0
		player.jump_buffer_timer = 0
		player.wall_jump_lock = 8
		
		state_machine.change_state("WallJump")
		player.audio_movements.volume_0_100 = 40.0
		player.audio_movements.play_stream(player.audio_jump)

func handle_input(event: InputEvent) -> void:
	if actor is Player2D:
		if event.is_action_pressed("ui_accept"):
			actor.jump_buffer_timer = 6
		
		elif event.is_action_pressed("Dash") and actor.can_dash and actor.dash_cooldown:
			actor.start_dash(true)
