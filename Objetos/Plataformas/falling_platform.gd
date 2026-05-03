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
var is_falling: bool = false

func _ready() -> void:
	set_physics_process(false)
	ManagerGame.time_stop.connect(_stop)
	ManagerGame.time_play.connect(_play)

func _stop() -> void:
	set_physics_process(false)
	animation.pause()
	respawn_timer.paused = true

func _play() -> void:
	if is_falling:
		set_physics_process(true)
	
	respawn_timer.paused = false

func _physics_process(delta: float) -> void:
	if ManagerGame.is_paused:
		return
	
	velocity.y += gravity * delta
	position += velocity * delta

func has_collided_with() -> void:
	if ManagerGame.is_paused:
		return
	
	if not is_triggered:
		is_triggered = true
		animation.play("shake")
		velocity = Vector2.ZERO

func _on_animation_animation_finished(_anim_name: StringName) -> void:
	if ManagerGame.is_paused:
		return
	
	is_falling = true
	set_physics_process(true)
	respawn_timer.start(reset_timer)

func _on_respawn_timer_timeout() -> void:
	set_physics_process(false)
	is_falling = false
	
	global_position = respswn_position
	velocity = Vector2.ZERO
	
	if is_triggered:
		var spawn_tween: Tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
		spawn_tween.tween_property(texture, "scale", Vector2.ONE, 0.2).from(Vector2.ZERO)
	
	is_triggered = false
