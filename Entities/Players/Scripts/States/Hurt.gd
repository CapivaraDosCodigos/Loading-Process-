extends PlayerState

var knockback: Vector2 = Vector2.ZERO

func enter(_previous_state_path: String, data: Dictionary = {}) -> void:
	player.animation.play(HURT)
	
	AudioManager.set_loop(AudioGame.PLAYER_SFX_2, false).set_pitch_random(true)
	AudioManager.play(AudioGame.PLAYER_SFX_2, player.audio_hurt, 540.0)
	
	var body_pos: Vector2 = data["body_pos"]
	
	var x_force: float = Vector2((player.global_position.x - body_pos.x), 0.0).normalized().x * player.knockback_height
	var y_force: float = -player.knockback_height if !MathGame.is_vertical_hit(player.global_position, body_pos) else player.knockback_height
	if is_zero_approx(x_force / 1000.0):
		x_force = [1.0, -1.0].pick_random() * player.knockback_height
	
	knockback = Vector2(x_force, y_force)
	
	var tween: Tween = player.create_tween()
	
	tween.parallel().tween_property(self, "knockback", Vector2.ZERO, 0.25)
	tween.parallel().tween_method(_set_shader_blink_intensity, 1.0, 0.0, 0.25)
	
	await tween.finished
	
	if player.buffer_jump.is_interval() and player.coyote_timer > 0:
		finished.emit(JUMP, {"velocity_add": player.velocity})
	elif player.can_wall_slide():
		finished.emit(WALL_SLIDE, {"velocity_add": player.velocity})
	elif not player.is_on_floor():
		finished.emit("Fall", {"velocity_add": player.velocity})
	else:
		finished.emit(RUN, {"velocity_add": player.velocity})

func physics_update(_delta: float) -> void:
	player.velocity = knockback
	player.dash_ghost_timer = 2

func get_name() -> StringName:
	return HURT

func _set_shader_blink_intensity(new_value: float) -> void:
	if player.animation.material:
		player.animation.material.set("shader_parameter/blink_intensity", new_value)
