@tool
extends Enemy2D
class_name EnemyGround2D

@export var wall_detector: RayCast2D
@export var ground_detector: RayCast2D

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_gravity(delta)
	
	if not (is_hurtet or is_stun):
		_apply_movement()
		
		if _should_flip():
			_apply_flip()
	else:
		velocity.x = 0.0
	
	move_and_slide()

func _apply_movement() -> void:
	if is_on_floor():
		velocity.x = direction.x * speed

func _apply_flip() -> void:
	direction *= -1.0
	wall_detector.scale.x = direction.x * -1.0
	
	if animated:
		animated.scale.x = direction.x * -1.0
	
	elif sprite:
		sprite.scale.x = direction.x * -1.0

func _should_flip() -> bool:
	if not wall_detector:
		return false
	
	return wall_detector.is_colliding() and is_on_floor()
