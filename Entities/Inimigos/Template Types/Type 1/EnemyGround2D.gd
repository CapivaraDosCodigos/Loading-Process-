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
		_should_flip()
		_apply_flips()
	else:
		velocity.x = 0.0
	
	move_and_slide()

func _apply_movement() -> void:
	if is_on_floor():
		velocity.x = direction.x * speed

func _apply_flips() -> void:
	if wall_detector:
		wall_detector.scale.x = direction.x
	
	if ground_detector:
		ground_detector.scale.x = direction.x
	
	if animated:
		animated.scale.x = direction.x
	
	elif sprite:
		sprite.scale.x = direction.x

func _should_flip() -> void:
	if not wall_detector:
		return
	
	if wall_detector.is_colliding() and is_on_floor():
		direction *= -1.0
