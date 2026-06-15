extends CopyBody2D

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	
	_apply_movement()
	
	move_and_slide()

func _apply_movement() -> void:
	velocity.x = speed * direction.x
