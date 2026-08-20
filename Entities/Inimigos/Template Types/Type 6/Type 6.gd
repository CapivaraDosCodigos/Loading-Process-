@tool
extends EnemyGround2D

@export_custom(PROPERTY_HINT_NONE, "suffix:px/s") var jump: float = 256.0

func _apply_movement() -> void:
	velocity.x = direction.x * speed
	if is_on_floor():
		velocity.y = -jump

func _should_flip() -> void:
	if not wall_detector:
		return
	
	if wall_detector.is_colliding():
		direction *= -1.0

func _apply_flips() -> void:
	if wall_detector:
		wall_detector.scale.x = direction.x
	
	if animated:
		animated.scale.x = direction.x
	
	elif sprite:
		sprite.scale.x = direction.x
