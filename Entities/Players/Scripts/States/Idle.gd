extends PlayerState

var pos_jump: bool = false

func enter(previous_state: String, _data: Dictionary = {}) -> void:
	if previous_state in [FALL, JUMP, HURT, WALL_SLIDE, WALL_SLIDE]:
		pos_jump = true
		player.animation.play(POS_JUMP)
		
		await player.animation.animation_finished
		
		pos_jump = false
		
	player.animation.play(IDLE)

func physics_update(delta: float) -> void:
	if pos_jump:
		return
	
	if not player.animation.animation == IDLE:
		player.animation.play(IDLE)
	
	if player.is_on_floor():
		player.can_dash = true
	
	player.velocity.y += player.fall_gravity * delta
	player.animation.scale.x = player.direction
	
	if handle_dash():
		return
	
	elif player.buffer_jump.is_interval() and player.coyote_timer > 0:
		finished.emit(JUMP)
	
	elif Game.get_input().x != 0.0 or !is_equal_approx(player.velocity.x, 0.0):
		finished.emit(RUN)
	
	elif player.can_wall_slide():
		finished.emit(WALL_SLIDE)
	
	elif not player.is_on_floor():
		finished.emit("Fall")

func get_name() -> StringName:
	return IDLE
