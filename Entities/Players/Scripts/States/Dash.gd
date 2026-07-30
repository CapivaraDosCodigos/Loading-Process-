extends PlayerState
#class_name DashState

var dash_velocity_add: Vector2
var dash_direction: Vector2

var dash_velocity_base: float = 1.0

var turnaround: bool = false

func enter(_previous_state: String, data: Dictionary = {}) -> void:
	player.animation.play(DASH)
	
	AudioManager.set_loop(AudioGame.PLAYER_SFX_2, false).set_pitch_random(true, 0.9, 1.1)
	AudioManager.play(AudioGame.PLAYER_SFX_2, Player2D.audio_dash, 100.0)
	
	if data.has("velocity_add"):
		dash_velocity_add = data["velocity_add"]
	
	player.buffer_dash.set_buffer_time()
	player.use_skills()
	
	player.can_dash = false
	player.dash_cooldown = false
	turnaround = false
	dash_velocity_base = 1.0
	
	var dir_input: Vector2 = Game.get_input().normalized()
	if dir_input != Vector2.ZERO:
		dash_direction = dir_input
	else:
		dash_direction = Vector2(player.direction, 0.0)
	
	start_attack()
	
	await player.get_tree().create_timer(player.dash_duration, false).timeout
	
	if player.buffer_jump.is_interval() and player.coyote_timer > 0:
		finished.emit(JUMP, {"velocity_add": player.velocity})
	elif player.can_wall_slide():
		finished.emit(WALL_SLIDE, {"velocity_add": player.velocity})
	elif not player.is_on_floor():
		finished.emit("Fall", {"velocity_add": player.velocity})
	else:
		finished.emit(RUN, {"velocity_add": player.velocity})

func physics_update(delta: float) -> void:
	player.velocity.x = player.dash_velocity * dash_direction.x * dash_velocity_base
	player.velocity.y = player.dash_velocity * dash_direction.y / 1.25
	
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

func get_name() -> StringName:
	return DASH

func exit() -> void:
	dash_direction = Vector2.ZERO
	
	end_attack()
	
	await player.get_tree().physics_frame
	await player.get_tree().physics_frame
	await player.get_tree().physics_frame
	
	player.dash_cooldown = true

func start_attack() -> void:
	player.set_collision_mask_value(3, false)
	player.set_collision_mask_value(7, false)
	player.modulate = Color.BLACK
	player.is_attack = true

func end_attack() -> void:
	player.set_collision_mask_value(3, true)
	player.set_collision_mask_value(7, true)
	player.modulate = Color.WHITE
	player.is_attack = false

func is_wall_slide() -> bool:
	if not player.has_wall_slide or turnaround:
		return false
	
	var touching_wall: bool = player.ray_right.is_colliding() or player.ray_left.is_colliding()
	return touching_wall
