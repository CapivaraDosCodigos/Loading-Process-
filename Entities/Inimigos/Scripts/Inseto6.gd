@tool
extends EnemyGround2D

@export var jump: float = 256.0

func _apply_movement() -> void:
	velocity.x = direction.x * speed
	if is_on_floor():
		velocity.y = -jump

func _should_flip() -> bool:
	if not wall_detector:
		return false
	
	return wall_detector.is_colliding()

func _apply_flip() -> void:
	direction *= -1.0
	wall_detector.scale.x = direction.x * -1.0
	
	if animated:
		animated.scale.x = direction.x * -1.0
	
	elif sprite:
		sprite.scale.x = direction.x * -1.0
