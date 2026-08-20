extends PlayerState

var is_pos_jump: bool = false
var is_turning: bool = false
var direction_input: float
var last_direction_input: float:
	set(value):
		if value == 0.0:
			return
		last_direction_input = value

func enter(previous_state: String, _data: Dictionary = {}) -> void:
	is_turning = false
	
	if previous_state in [FALL, JUMP, HURT, WALL_SLIDE, WALL_SLIDE]:
		is_pos_jump = true
		player.animation.play(POS_JUMP)
		await player.animation.animation_finished
		is_pos_jump = false
	
	player.animation.play(RUN)

func physics_update(delta: float) -> void:
	if is_pos_jump:
		return
	
	player.can_dash = true
	direction_input = Inputs.get_input().x
	
	if not is_turning and direction_input != 0.0 and last_direction_input != 0.0:
		if sign(direction_input) != sign(last_direction_input):
			_trigger_turn()
	
	handle_movement(delta)
	
	if not is_turning:
		player.animation.scale.x = player.direction
	
	if handle_dash():
		return
	
	elif is_equal_approx(player.velocity.x, 0.0):
		finished.emit(IDLE)
	
	elif player.buffer_jump.is_interval() and player.coyote_timer > 0:
		finished.emit(JUMP)
	
	elif can_wall_slide():
		finished.emit(WALL_SLIDE)
	
	elif not player.is_on_floor():
		finished.emit(FALL)
	
	last_direction_input = direction_input

func _trigger_turn() -> void:
	if not is_active(): return
	is_turning = true
	player.animation.play("Run Turn")
	
	await player.animation.animation_finished
	
	if not is_active(): return
	if is_turning:
		is_turning = false
		player.animation.scale.x = player.direction
		player.animation.play(RUN)

func handle_movement(delta: float) -> void:
	player.direction = direction_input
	
	if is_turning:
		player.velocity.x = lerp(player.velocity.x, direction_input * player.speed, 0.84)
		return
	
	if player.velocity.abs().x > player.speed:
		if player.velocity.sign().x != direction_input:
			player.velocity.x = lerp(player.velocity.x, direction_input * player.speed, delta * 10.0)
		return
	
	player.velocity.x = direction_input * player.speed

func handle_dash()-> bool:
	if player.buffer_dash.is_interval() and player.dash_cooldown:
		finished.emit(DASH)
		player.buffer_dash.set_buffer_time()
		return true
	return false

func get_name() -> StringName:
	return RUN

func exit() -> void:
	is_turning = false
