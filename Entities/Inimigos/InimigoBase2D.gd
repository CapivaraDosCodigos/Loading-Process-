extends CharacterBody2D
class_name InimigoBase2D

var direction: int = -1
var is_hurtet: bool = false

@export var SPEED: float = 900.0
@export var score: int = 10
@export_group("Nodes")
@export var wall_detector: RayCast2D
@export var animated: AnimatedSprite2D

func _ready() -> void:
	EventBus.time_stop.connect(_stop)
	EventBus.time_play.connect(_play)
	_internal_ready()
	if EventBus.is_paused:
		_stop()

func _internal_ready() -> void:
	pass

func _stop() -> void:
	pass

func _play() -> void:
	pass

func _is_hurt_velocity() -> bool:
	if is_hurtet:
		velocity = Vector2.ZERO
	return is_hurtet

func _gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _movement(delta: float) -> void:
	if is_on_floor():
		velocity.x = direction * SPEED * delta
	
	move_and_slide()

func _flip_direction() -> void:
	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale *= -1
	
	animated.flip_h = direction == 1

func _on_animated_animation_finished() -> void:
	if animated.animation == "Hurt":
		EventBus.score += score
		queue_free()

func take_damage() -> void:
	velocity = Vector2.ZERO
	is_hurtet = true
	var knockback_tween: Tween = create_tween()
	animated.modulate = Color.RED
	knockback_tween.tween_property(animated, "modulate", Color.WHITE, 0.25)
	animated.play("Hurt")
