extends PlayerState
#class_name DashState

var dash_direction: Vector2
var dash_velocity_base: float = 1.0
var turnaround: bool = false

func enter(_previous_state_path: String, _data: Dictionary = {}) -> void:
	player.animation.play(JUMP)
	player.can_dash = false
	player.dash_cooldown = false
	turnaround = false
	dash_velocity_base = 1.0
	
	var dir_input: Vector2 = Game.get_input().normalized()
	if dir_input != Vector2.ZERO:
		dash_direction = dir_input
	else:
		dash_direction = Vector2(player.direction, 0.0)
	
	AudioManager.set_loop(AudioGame.PLAYER_SFX_2, false).set_pitch_random(true, 0.9, 1.1)
	AudioManager.play(AudioGame.PLAYER_SFX_2, Player2D.audio_dash, 100.0)
	
	await get_tree().create_timer(player.dash_duration, false).timeout
	
	if player.buffer_jump.is_interval() and player.coyote_timer > 0:
		finished.emit(JUMP, {"velocity_add": player.velocity})
	
	elif player.can_wall_slide():
		finished.emit(WALL_SLIDE, {"velocity_add": player.velocity})
	
	elif not player.is_on_floor():
		finished.emit("Fall", {"velocity_add": player.velocity})
	
	else:
		finished.emit(RUN, {"velocity_add": player.velocity})
		
	dash_direction = Vector2.ZERO
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	player.dash_cooldown = true

func physics_update(delta: float) -> void:
	player.velocity.x = player.dash_velocity * dash_direction.x * dash_velocity_base
	player.velocity.y = player.dash_velocity * dash_direction.y / 1.5
	
	if dash_direction.x != 0.0:
		player.animation.scale.x = MathGame.desnormalized(dash_direction).x
	
	if turnaround and dash_direction.y == 0.0:
		player.velocity.y += player.fall_gravity * delta * 4.0
	
	if is_wall_slide():
		var wall_direction: float = -1.0 if player.ray_right.is_colliding() else 1.0
		if wall_direction == dash_direction.x * -1.0:
			dash_direction.x *= -1.0
			turnaround = true
			dash_velocity_base = 0.9
			player.direction *= -1.0
	
	if player.is_on_floor() and dash_direction.y == 1.0:
		dash_direction.y = -1.0
		turnaround = true
		dash_velocity_base = 0.9
		player.direction *= -1.0

func is_wall_slide() -> bool:
	if not player.has_wall_slide or turnaround:
		return false
	
	var touching_wall: bool = player.ray_right.is_colliding() or player.ray_left.is_colliding()
	return touching_wall
