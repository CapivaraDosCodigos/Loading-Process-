extends CharacterBody2D

const SPEED = 900.0
var direction: int = -1

@onready var wall_detector: RayCast2D = $Wall_detector
@onready var animated: AnimatedSprite2D = $Animated

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale *= -1
	
	animated.flip_h = direction == 1
	
	velocity.x = direction * SPEED * delta

	move_and_slide()

func _on_animated_animation_finished() -> void:
	if animated.animation == "Hurt":
		queue_free()
