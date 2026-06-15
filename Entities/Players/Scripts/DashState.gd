extends PlayerState
#class_name DashState

var dash_direction: Vector2
var dash_velocity_base: float = 1.0
var turnaround: bool = false

func enter(_previous_state_path: String, _data: Dictionary = {}) -> void:
	player.animation.play("Jump")
	player.can_dash = false
	player.dash_cooldown = false
	turnaround = false
	dash_velocity_base = 1.0
	
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

func physics_update(delta: float) -> void:
	player.velocity.x = (player.dash_distance / player.dash_duration) * dash_direction.x * dash_velocity_base
	player.velocity.y = (player.dash_distance / player.dash_duration) * dash_direction.y / 1.5
	
	if dash_direction.x != 0.0:
		player.animation.scale.x = dash_direction.x
	
	if turnaround:
		player.apply_gravity(delta * 2.0)
	
	if player.dash_ghost_timer == 0:
		player.create_ghost_sprite()
		player.dash_ghost_timer = 3
	
	if is_wall_slide() and dash_direction.x == 0.0:
		var wall_direction: float = -1.0 if player.ray_right.is_colliding() else 1.0
		if wall_direction == dash_direction.x * -1.0:
			dash_direction.x *= -1.0
			turnaround = true
			dash_velocity_base = 0.9
			player.direction *= -1.0

func is_wall_slide() -> bool:
	if not player.has_wall_slide or turnaround:
		return false
	
	var touching_wall: bool = player.ray_right.is_colliding() or player.ray_left.is_colliding()
	return touching_wall
