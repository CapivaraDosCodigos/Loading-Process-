extends CharacterBody2D
class_name CopyBody2D

var direction: Vector2 = Vector2.LEFT

var is_hurtet: bool = false
var take_damage_force: bool = false

var HP: int = 1

@export var HP_base: int = 1
@export var score: int = 10

@export var speed: float = 20.0

@export var distortion_position: float = 1.6
@export var distortion: Vector2 = Vector2(1.2, 0.8)

@export_group("Nodes")
@export var collision: CollisionShape2D
@export var hitbox: AreaHitbox2D
@export var wall_detector: RayCast2D
@export var sprite: Sprite2D
@export var animated: AnimatedSprite2D
@export var animation_player: AnimationPlayer

func _ready() -> void:
	if animated:
		animated.animation_finished.connect(_on_animated_finished)
	
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_player_finished)
	
	_internal_flip()
	
	_internal_ready()
	
	HP = HP_base

func _internal_ready() -> void:
	pass

func _gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _movement() -> void:
	pass

func _flip_direction() -> void:
	pass

func _internal_flip() -> void:
	direction.x = scale.y * -1.0
	scale.y = 1.0
	rotation = 0.0
	
	if wall_detector:
		wall_detector.scale.x = direction.x * -1.0
	
	if animated:
		animated.scale.x = direction.x * -1.0
	
	elif sprite:
		sprite.scale.x = direction.x * -1.0

func _on_animated_finished() -> void:
	if animated.animation == "Hurt":
		queue_free()

func _on_animation_player_finished(animated_name: StringName) -> void:
	if animated_name == "Hurt":
		queue_free()

func take_damage(inimigo: InimigoBase2D) -> void:
	if inimigo:
		inimigo.take_damage(null)
	
	velocity = Vector2.ZERO
	is_hurtet = true
	
	_apply_effects()
	
	animated.play("Hurt")

func _apply_effects() -> void:
	var knockback_tween: Tween = create_tween()
	
	if animated:
		if animated.material:
			animated.material.set("shader_parameter/blink_intensity", 1.0)
			knockback_tween.parallel().tween_property(animated.material, "shader_parameter/blink_intensity", 0.0, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TransitionType.TRANS_ELASTIC)
		
		animated.scale = Vector2(-direction.x * distortion.x, distortion.y)
		var save_position: Vector2 = animated.position
		animated.position.y += distortion_position
		
		knockback_tween.parallel().tween_property(animated, "modulate", Color.WHITE, 0.25)
		knockback_tween.parallel().tween_property(animated, "scale", Vector2(direction.x * -1.0, 1.0), 0.25)
		knockback_tween.parallel().tween_property(animated, "position", save_position, 0.25)
	
	elif sprite:
		sprite.material.set("shader_parameter/blink_intensity", 1.0)
		sprite.scale = Vector2(-direction.x * distortion.x, distortion.y)
		var save_position: Vector2 = sprite.position
		sprite.position.y += distortion_position
		
		knockback_tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.25)
		knockback_tween.parallel().tween_property(sprite, "scale", Vector2(direction.x * -1.0, 1.0), 0.25)
		knockback_tween.parallel().tween_property(sprite, "position", save_position, 0.25)
		knockback_tween.parallel().tween_property(sprite.material, "shader_parameter/blink_intensity", 0.0, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TransitionType.TRANS_ELASTIC)
