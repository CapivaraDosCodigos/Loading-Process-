extends CharacterBody2D
class_name Player2D

const AIR_FRICTION: float = 0.5

@export var SPEED: float = 200.0

@onready var animation: AnimatedSprite2D = $Animation
@onready var animator: AnimationPlayer = $Animator
@onready var remote_camera: RemoteTransform2D = $RemoteCamera
@onready var ray_right: RayCast2D = $RayRight
@onready var ray_left: RayCast2D = $RayLeft

signal player_has_died()

static var audio_jump: AudioStream:
	get():
		if not audio_jump:
			audio_jump = preload("uid://oirh41homqht")
		return audio_jump

var direction: float = 1.0
#var is_jumping: bool = false
var is_off_screen: bool = false
var is_hurtet: bool = false
var knockback_vector: Vector2 = Vector2.ZERO

@export var jump_height: float = 64.0
@export var max_time_to_peak: float = 0.5

var jump_velocity: float
var gravity: float
var fall_gravity: float

func _ready() -> void:
	jump_velocity = (jump_height * 2.0) / max_time_to_peak
	gravity = (jump_height * 2.0) / pow(max_time_to_peak, 2)
	fall_gravity = gravity * 2.0
	
func _physics_process(delta: float) -> void:
	if Global.paused_transition:
		_set_state()
		return
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -jump_velocity
		AudioManager.play(3 as AudioManager.AudioType, audio_jump, 60.0)
		#is_jumping = true
		#
	#elif is_on_floor():
		#is_jumping = false
	if velocity.y > 0.0 or not Input.is_action_pressed("ui_accept"):
		velocity.y += fall_gravity * delta
	else:
		velocity.y += gravity * delta
	
	direction = Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = lerp(velocity.x, direction * SPEED, AIR_FRICTION)
		animation.flip_h = direction == -1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
	
	_set_state()
	move_and_slide()
	
	for platform in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(platform)
		var collider := collision.get_collider()
		
		if collider is FallingPlatform2D:
			collider.has_collided_with()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Ability"):
		_use_ability()
	
	elif event.is_action_pressed("TimeStop"):
		if not Global.is_paused:
			Global.time_stop_event()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if is_hurtet:
		return
	
	if body.is_in_group("Projectiles"):
		take_damage(Vector2(0.0, -50.0))
		
	elif ray_right.is_colliding():
		take_damage(Vector2(-200.0, -200.0))
		
	elif ray_left.is_colliding():
		take_damage(Vector2(200.0, -200.0))
		
	else:
		take_damage(Vector2.ZERO)

func _on_notifier_screen_exited() -> void:
	is_off_screen = true
	#await get_tree().create_timer(1.0).timeout
	if is_off_screen:
		queue_free()
		player_has_died.emit()

func _on_notifier_screen_entered() -> void:
	is_off_screen = false

func _set_state() -> void:
	var state: StringName = "Idle"
	
	if !is_on_floor():
		state = "Jump"
	elif direction != 0.0:
		state = "Run"
	
	if is_hurtet:
		state = "Hurt"
	
	if animation.animation != state:
		animation.play(state)

func _use_ability() -> void:
	pass

func follow_camera(camera: Camera2D) -> void:
	var camera_path: NodePath = camera.get_path()
	remote_camera.remote_path = camera_path

func take_damage(knockback_force: Vector2, duration: float = 0.25) -> void:
	if Global.player_life:
		Global.player_life -= 1
	else:
		queue_free()
		player_has_died.emit()
	
	knockback_vector = knockback_force
	var knockback_tween: Tween = create_tween()
	knockback_tween.parallel().tween_property(self, "knockback_vector", Vector2.ZERO, duration)
	animation.modulate = Color.RED
	knockback_tween.parallel().tween_property(animation, "modulate", Color.WHITE, duration)
	
	is_hurtet = true
	await get_tree().create_timer(duration, false).timeout
	is_hurtet = false
