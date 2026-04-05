extends CharacterBody2D
class_name InimigoBase2D

var direction: Vector2 = Vector2(-1.0, 0)
var is_hurtet: bool = false

@export var speed: float = 20.0
@export var score: int = 10

@export_group("Nodes")
@export var wall_detector: RayCast2D
@export var animated: AnimatedSprite2D

func _ready() -> void:
	Global.time_stop.connect(_stop)
	Global.time_play.connect(_play)
	_internal_ready()
	if Global.is_paused:
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

func _movement() -> void:
	if is_on_floor():
		velocity.x = direction.x * speed
	
	move_and_slide()

func _flip_direction() -> void:
	if wall_detector:
		if wall_detector.is_colliding():
			direction *= -1.0
			wall_detector.scale.x = direction.x * -1.0
	
	if animated:
		animated.flip_h = direction.x == 1.0

func _on_animated_animation_finished() -> void:
	if animated.animation == "Hurt":
		Global.score += score
		queue_free()

func take_damage(player: Player2D = null) -> void:
	if player:
		player.velocity.y = -player.jump_velocity
	
	velocity = Vector2.ZERO
	is_hurtet = true
	var knockback_tween: Tween = create_tween()
	animated.modulate = Color.RED
	knockback_tween.tween_property(animated, "modulate", Color.WHITE, 0.25)
	animated.play("Hurt")
