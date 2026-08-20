extends PlayerState

var dash_ghost_timer: int = 0
var dash_direction: Vector2

func enter(_previous_state: String, _data: Dictionary = {}) -> void:
	player.animation.play(DASH)
	
	AudioManager.set_loop(AudioGame.PLAYER_SFX_2, false).set_pitch_random(true, 0.9, 1.1)
	AudioManager.play(AudioGame.PLAYER_SFX_2, Player2D.audio_dash, 100.0)
	
	player.buffer_dash.set_buffer_time()
	
	player.can_dash = false
	player.dash_cooldown = false

	var dir_input: Vector2 = Inputs.get_input().normalized()
	if dir_input != Vector2.ZERO:
		dash_direction = dir_input
	else:
		dash_direction = Vector2(player.direction, 0.0)
	
	start_attack()
	
	player.dash_timer = player.get_tree().create_timer(player.dash_duration, false)
	await player.dash_timer.timeout
	
	if player.buffer_jump.is_interval() and player.coyote_timer > 0:
		finished.emit(JUMP)
	elif can_wall_slide():
		finished.emit(WALL_SLIDE)
	elif not player.is_on_floor():
		finished.emit(FALL)
	else:
		finished.emit(RUN)

func physics_update(_delta: float) -> void:
	player.velocity.x = player.dash_velocity * dash_direction.x
	player.velocity.y = player.dash_velocity * dash_direction.y / 1.25
	
	if dash_direction.x != 0.0:
		player.animation.scale.x = MathGame.desnormalized(dash_direction).x
	
	if player.ray_right.is_colliding() and dash_direction.x == 1.0:
		dash_direction.x *= -1.0
		player.direction *= -1.0
		_reduce_dash_time()
	elif player.ray_left.is_colliding() and dash_direction.x == -1.0:
		dash_direction.x *= -1.0
		player.direction *= -1.0
		_reduce_dash_time()
	elif (player.ray_up.is_colliding() or player.is_on_ceiling()) and dash_direction.y == -1.0:
		dash_direction.y *= -1.0
		_reduce_dash_time()
	elif (player.ray_down.is_colliding() or player.is_on_floor()) and dash_direction.y == 1.0:
		dash_direction.y *= -1.0
		_reduce_dash_time()
	
	if dash_ghost_timer > 0:
		dash_ghost_timer -= 1
	else:
		create_ghost_sprite()
		dash_ghost_timer = 1

func get_name() -> StringName:
	return DASH

func exit() -> void:
	dash_direction = Vector2.ZERO
	
	end_attack()
	
	#await player.get_tree().physics_frame
	#await player.get_tree().physics_frame
	#await player.get_tree().physics_frame
	
	await player.get_tree().create_timer(player.dash_duration, false).timeout
	
	player.dash_cooldown = true

func _reduce_dash_time() -> void:
	if is_zero_approx(player.dash_timer.time_left):
		player.dash_timer.time_left /= 1.25

func start_attack() -> void:
	#player.modulate = Color.BLACK
	player.is_attack = true

func end_attack() -> void:
	player.modulate = Color.WHITE
	player.is_attack = false

func create_ghost_sprite() -> void:
	var anim: AnimatedSpriteShader2D = player.animated_shader.instantiate()
	anim.sprite_frames = player.animation.sprite_frames
	anim.animation = player.animation.animation
	anim.frame = player.animation.frame
	anim.flip_h = player.animation.flip_h
	anim.global_position = player.global_position
	anim.scale = player.animation.scale
	player.add_sibling(anim)
	anim.stop()
