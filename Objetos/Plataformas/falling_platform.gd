extends AnimatableBody2D
class_name FallingPlatform2D

@onready var animation: AnimationPlayer = $Animation
@onready var respawn_timer: Timer = $RespawnTimer
@onready var respswn_position: Vector2 = global_position
@onready var texture: Sprite2D = $Texture

@export var reset_timer: float = 3.0

var velocity: Vector2 = Vector2.ZERO
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_triggered: bool = false

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta

func has_collided_with(collision: KinematicCollision2D, collider: CharacterBody2D) -> void:
	if not is_triggered:
		is_triggered = true
		animation.play("shake")
		velocity = Vector2.ZERO

func _on_animation_animation_finished(_anim_name: StringName) -> void:
	set_physics_process(true)
	respawn_timer.start(reset_timer)

func _on_respawn_timer_timeout() -> void:
	set_physics_process(false)
	global_position = respswn_position
	if is_triggered:
		var spawn_tween: Tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
		spawn_tween.tween_property(texture, "scale", Vector2.ONE, 0.2).from(Vector2.ZERO)
		
		
	
	is_triggered = false
