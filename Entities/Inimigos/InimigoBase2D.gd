@tool
extends CharacterBody2D
class_name Enemy2D

const HURT = "Hurt"

enum TypeAnimation { Sprite, AnimatedSprite, None }

var direction: Vector2 = Vector2.LEFT:
	set(value):
		direction = value.sign()
var is_hurtet: bool = false
var is_stun: bool = false
var health_point: int = 1:
	set(value):
		health_point = max(0, value)

@export var health_point_base: int = 1
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s") var speed: float = 20.0
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var size: Vector2 = Vector2(16.0, 16.0)

@export_group("Distortion")
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var distortion_position: float = 1.6
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var distortion: Vector2 = Vector2(1.2, 0.8)

@export_group("Animation")
@export var animation_type: TypeAnimation = TypeAnimation.AnimatedSprite:
	set(value):
		animation_type = value
		notify_property_list_changed()
@export var animated: AnimatedSprite2D:
	get():
		if animation_type != TypeAnimation.AnimatedSprite or animated:
			return animated
		
		for node in get_children():
			if node is AnimatedSprite2D:
				animated = node
				break
		
		return animated
@export var sprite: Sprite2D:
	get():
		if animation_type != TypeAnimation.Sprite or sprite:
			return sprite
		
		for node in get_children():
			if node is Sprite2D:
				sprite = node
				break
		
		return sprite
@export var animation_player: AnimationPlayer:
	get():
		if animation_type != TypeAnimation.Sprite or animation_player:
			return animation_player
		
		for node in get_children():
			if node is AnimationPlayer:
				animation_player = node
				break
		
		return animation_player

@export_group("Nodes")
@export var collision: CollisionShape2D
@export var hitbox: AreaHitbox2D

func _init() -> void:
	if Engine.is_editor_hint():
		return
	add_to_group("Inimigos")
	health_point = health_point_base

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if animated:
		animated.animation_finished.connect(_on_animated_finished)
	
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_player_finished)

func _validate_property(property: Dictionary) -> void:
	if property.name == "animated":
		if animation_type != TypeAnimation.AnimatedSprite:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name in ["sprite", "animation_player"]:
		if animation_type != TypeAnimation.Sprite:
			property.usage = PROPERTY_USAGE_NO_EDITOR

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if !animated and animation_type == TypeAnimation.AnimatedSprite:
		warnings.append("Considere adicionar um AnimatedSprite2D ao nó")
	
	if !animation_player and animation_type == TypeAnimation.Sprite:
		warnings.append("Considere adicionar um AnimationPlayer ao nó")
	
	if !sprite and animation_type == TypeAnimation.Sprite:
		warnings.append("Considere adicionar um Sprite ao nó")
	
	return warnings

func _gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _apply_movement() -> void:
	pass

func _apply_flips() -> void:
	pass

func _apply_hurt_effects() -> void:
	var knockback_tween: Tween = create_tween()
	
	play(HURT)
	
	var target2D: Node2D
	
	if animated:
		target2D = animated
	elif sprite:
		target2D = sprite
	else:
		return
	
	if target2D.material:
		target2D.material.set("shader_parameter/blink_intensity", 1.0)
		knockback_tween.parallel().tween_property(target2D.material, "shader_parameter/blink_intensity", 0.0, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TransitionType.TRANS_ELASTIC)
	
	target2D.scale = Vector2(-direction.x * distortion.x, distortion.y)
	var save_position: Vector2 = target2D.position
	target2D.position.y += distortion_position
	
	knockback_tween.parallel().tween_property(target2D, "modulate", Color.WHITE, 0.25)
	knockback_tween.parallel().tween_property(target2D, "scale", Vector2(direction.x * -1.0, 1.0), 0.25)
	knockback_tween.parallel().tween_property(target2D, "position", save_position, 0.25)

func _die() -> void:
	if Engine.is_editor_hint():
		return
	
	queue_free()

func _on_animated_finished() -> void:
	if animated.animation == HURT:
		if health_point <= 0:
			_die()

func _on_animation_player_finished(animated_name: StringName) -> void:
	if animated_name == HURT:
		if health_point <= 0:
			_die()

func play(name_animation: StringName = &"") -> void:
	if animation_type == TypeAnimation.AnimatedSprite:
		if animated and animated.sprite_frames.has_animation(name_animation):
			animated.play(name_animation)
	
	elif animation_type == TypeAnimation.AnimatedSprite:
		if animation_player and animation_player.has_animation(name_animation):
			animation_player.play(name_animation)

func pause() -> void:
	if animation_type == TypeAnimation.AnimatedSprite and animated:
		animated.pause()
	
	elif animation_type == TypeAnimation.AnimatedSprite and animation_player:
		animation_player.pause()

func set_disabled_collision(value: bool) -> void:
	if collision:
		collision.set_deferred("disabled", value)

func take_damage(player: Player2D = null) -> void:
	set_collision_layer_value(3, false)
	
	if player:
		var time_size: float = (size.x + 4.0) / player.dash_velocity
		player.dash_timer.time_left = max(time_size, player.dash_timer.time_left)
	
	velocity = Vector2.ZERO
	is_hurtet = true
	health_point -= 1
	
	_apply_hurt_effects()

func apply_stun(duration: float = 0.30) -> void:
	is_stun = true
	
	animated.speed_scale = 0.5
	
	await get_tree().create_timer(duration).timeout
	
	animated.speed_scale = 1.0
	
	is_stun = false
