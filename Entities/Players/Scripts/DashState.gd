extends PlayerState
#class_name DashState

var dash_direction: Vector2

func enter(_previous_state_path: String, _data: Dictionary = {}) -> void:
	player.animation.play("Jump")
	player.can_dash = false
	player.dash_cooldown = false
	
	var dir_input := Input.get_vector("ui_left", "ui_right", "ui_up","ui_down")
	if dir_input != Vector2.ZERO:
		dash_direction = dir_input
	else:
		dash_direction = Vector2(player.direction, 0.0)
	
	AudioManager.set_loop(AudioGame.PLAYER_SFX_2, false).set_pitch_random(true, 0.9, 1.1)
	AudioManager.play(AudioGame.PLAYER_SFX_2, Player2D.audio_dash, 100.0)
	
	await get_tree().create_timer(player.dash_duration, false).timeout
	
	finished.emit(RUN)
	
	if player.buffer_jump.is_interval() and player.coyote_timer > 0:
		finished.emit(JUMP)
	
	elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		finished.emit(RUN)
	
	elif player.can_wall_slide():
		finished.emit("WallSlide")
	
	dash_direction = Vector2.ZERO
	
	player.dash_ghost_timer = 0
	#player.velocity = Vector2.ZERO
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	player.dash_cooldown = true

func physics_update(_delta: float) -> void:
	#print(Time.get_ticks_msec())
	player.velocity.x = (player.dash_distance / player.dash_duration) * dash_direction.x
	player.velocity.y = (player.dash_distance / player.dash_duration) * dash_direction.y / 1.5
	
	#player.velocity.y = 0.0
	#player.move_velocity.x = lerp(player.move_velocity.x, 0.0, player.AIR_FRICTION)

	if player.dash_ghost_timer == 0:
		player.create_ghost_sprite()
		player.dash_ghost_timer = 3
