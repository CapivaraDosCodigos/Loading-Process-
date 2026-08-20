extends PlayerState

var is_pos_jump: bool = false

func enter(previous_state: String, _data: Dictionary = {}) -> void:
	if previous_state in [FALL, JUMP, HURT, WALL_SLIDE, WALL_SLIDE]:
		is_pos_jump = true
		player.animation.play(POS_JUMP)
		
		await player.animation.animation_finished
		
		is_pos_jump = false
		
	player.animation.play(IDLE)

func physics_update(_delta: float) -> void:
	if is_pos_jump:
		return
	
	if not player.animation.animation == IDLE:
		player.animation.play(IDLE)
	
	player.can_dash = true
	player.animation.scale.x = player.direction
	
	if handle_dash():
		return
	
	elif player.buffer_jump.is_interval() and player.coyote_timer > 0:
		finished.emit(JUMP)
	
	if Inputs.is_input_horizontal():
		finished.emit(RUN)
	
	elif can_wall_slide():
		finished.emit(WALL_SLIDE)
	
	elif not player.is_on_floor():
		finished.emit(FALL) 

func get_name() -> StringName:
	return IDLE
