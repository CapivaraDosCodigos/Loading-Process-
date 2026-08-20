extends PlayerState

var direction_input: float

func enter(_previous_state_path: String, _data: Dictionary = {}) -> void:
	player.animation.play(FALL)

func physics_update(delta: float) -> void:
	handle_movement(delta)
	
	player.velocity.y += player.gravity * delta
	player.animation.scale.x = player.direction
	
	if player.is_on_floor():
		if player.buffer_jump.is_interval():
			finished.emit(JUMP)
		elif is_equal_approx(player.velocity.x, 0.0):
			finished.emit(IDLE)
		else:
			finished.emit(RUN)
	
	elif player.coyote_timer > 0 and player.buffer_jump.is_interval():
		finished.emit(JUMP)
	
	elif handle_dash():
		return
	
	elif can_wall_slide():
		finished.emit(WALL_SLIDE)

func handle_movement(delta: float) -> void:
	direction_input = Inputs.get_input().x
	player.direction = direction_input
	
	if player.velocity.abs().x > player.speed:
		if player.velocity.sign().x != direction_input:
			player.velocity.x = lerp(player.velocity.x, direction_input * player.speed, delta)
		return
	
	player.velocity.x = direction_input * player.speed

func get_name() -> StringName:
	return FALL

func handle_dash()-> bool:
	if player.buffer_dash.is_interval() and player.can_dash and player.dash_cooldown:
		finished.emit(DASH)
		return true
	return false
