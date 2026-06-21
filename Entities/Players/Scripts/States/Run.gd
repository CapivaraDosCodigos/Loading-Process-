extends PlayerState

var dash_velocity_add: Vector2

func enter(_previous_state_path: String, data: Dictionary = {}) -> void:
	player.animation.play(RUN)
	
	if data.has("velocity_add"):
		dash_velocity_add = data["velocity_add"]

func physics_update(delta: float) -> void:
	handle_movement()
	
	if player.is_on_floor():
		player.can_dash = true
	
	player.apply_gravity(delta)
	
	if handle_dash():
		return
	
	elif player.buffer_jump.is_interval() and player.coyote_timer > 0:
		finished.emit(JUMP)
	
	elif is_equal_approx(player.velocity.x, 0.0):
		finished.emit(IDLE)
	
	elif player.can_wall_slide():
		finished.emit(WALL_SLIDE)

func handle_movement() -> void:
	var direction_input: float = Game.get_input().x
	
	var velocity_add: Vector2 = Vector2.ZERO
	
	if MathGame.desnormalized(dash_velocity_add).x == direction_input:
		#velocity_add.x = abs(dash_velocity_add.x) - player.speed if abs(dash_velocity_add.x) - player.speed > 0.0 else 0
		velocity_add.x = dash_velocity_add.abs().x
		
	dash_velocity_add = dash_velocity_add.lerp(Vector2.ZERO, player.AIR_FRICTION / 10.0)
	
	if player.wall_jump_lock != 0 and dash_velocity_add == Vector2.ZERO:
		return
	
	if not player.is_on_floor() and dash_velocity_add == Vector2.ZERO:
		player.velocity.x = 0.0
	
	if direction_input != 0.0:
		player.direction = direction_input
		#player.velocity.x = player.direction * (player.speed + velocity_add.x)
		player.velocity.x = player.direction * max(player.speed, velocity_add.x)
		player.animation.scale.x = player.direction 
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.speed)

func handle_dash()-> bool:
	if player.buffer_dash.is_interval() and player.can_dash and player.dash_cooldown:
		if player.has_dash:
			finished.emit(DASH)
			return true
		player.buffer_dash.set_buffer_time()
		player.use_skills()
	return false
