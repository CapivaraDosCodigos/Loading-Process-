extends PlayerState
#class_name HurtState

func enter(_previous_state_path: String, data: Dictionary = {}) -> void:
	var knockback_force: Vector2 = data["knockback_force"]
	var duration: float = data["duration"]
	var vertical_hit: bool = data["vertical_hit"]
	
	AudioManager.set_loop(AudioGame.PLAYER_SFX_1, false).set_pitch_random(true, 0.8, 1.2)
	AudioManager.play(AudioGame.PLAYER_SFX_1, player.audio_hurt, 90.0)
	ManagerGame.camera.shake(2.0, duration)
	
	player.knockback_vector = knockback_force
	var knockback_tween: Tween = create_tween()
	var hurt_direction: float = player.direction
	
	knockback_tween.parallel().tween_property(player, "knockback_vector", Vector2.ZERO, duration)
	knockback_tween.parallel().tween_method(_set_shader_blink_intensity, 1.0, 0.0, duration)
	
	if vertical_hit:
		player.animation.scale = Vector2(1.1 * hurt_direction, 0.9)
		var save_position: Vector2 = player.animation.position
		player.animation.position.y += 1.6

		knockback_tween.parallel().tween_property(
			player.animation,
			"scale",
			Vector2(hurt_direction, 1.0),
			duration
		)
		knockback_tween.parallel().tween_property(
			player.animation,
			"position",
			save_position,
			duration
		)

	else:
		player.animation.scale = Vector2(0.9 * hurt_direction, 1.1)
		var save_position: Vector2 = player.animation.position
		player.animation.position.y -= 1.6

		knockback_tween.parallel().tween_property(
			player.animation,
			"scale",
			Vector2(hurt_direction, 1.0),
			duration
		)
		knockback_tween.parallel().tween_property(player.animation,
			"position",
			save_position,
			duration
		)
	
	player.particles.emit(Vector2(sign(knockback_force.x), -sign(knockback_force.y)))
	player.dash_cooldown = false
	finished.emit(IDLE)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	player.dash_cooldown = true

func physics_update(delta: float) -> void:
	if player.knockback_vector.x != 0:
		player.velocity.x = player.knockback_vector.x

	if player.knockback_vector.y != 0:
		player.velocity.y = player.knockback_vector.y
	else:
		player.velocity.y += player.fall_gravity * delta

func _set_shader_blink_intensity(new_value: float) -> void:
	player.animation.material.set("shader_parameter/blink_intensity", new_value)
