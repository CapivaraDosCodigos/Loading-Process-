extends CharacterBody2D
class_name Player2D

@export var SPEED: float = 200.0
@export var JUMP_FORCE: float = -300.0
@export var life: int = 100

@onready var animation: AnimatedSprite2D = $Animation
@onready var remote_camera: RemoteTransform2D = $RemoteCamera
@onready var ray_right: RayCast2D = $RayRight
@onready var ray_left: RayCast2D = $RayLeft

var direction: float = 1.0

#var is_jumping: bool = false
var is_hurtet: bool = false
var knockback_vector: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		#$Animator.play_backwards("Time Stop")
		#is_jumping = true
		#
	#elif is_on_floor():
		#is_jumping = false
	
	direction = Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * SPEED
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
			collider.has_collided_with(collision, self)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Ability"):
		_use_ability()
	
	elif event.is_action_pressed("TimeStop"):
		_time_stop()

func _on_hurtbox_body_entered(_body: Node2D) -> void:
	if life < 0:
		queue_free()

	elif ray_right.is_colliding():
		take_damage(Vector2(-200, -200))
		
	elif ray_left.is_colliding():
		take_damage(Vector2(200, -200))
	else:
		take_damage(velocity)

func _on_head_area_body_entered(body: Node2D) -> void:
	if body is BreakBox2D:
		body.break_sprites()

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

func _time_stop() -> void:
	if not $Animator.is_playing():
		$Animator.play("Time Stop")
		await $Animator.animation_finished
		await get_tree().create_timer(9.0).timeout
		$Animator.play_backwards("Time Stop")

func follow_camera(camera: Camera2D) -> void:
	var camera_path: NodePath = camera.get_path()
	remote_camera.remote_path = camera_path

func take_damage(knockback_force: Vector2, duration: float = 0.25) -> void:
	life -= 1
	
	#if knockback_force == Vector2.ZERO:
		#return
	
	knockback_vector = knockback_force
	var knockback_tween: Tween = create_tween()
	knockback_tween.parallel().tween_property(self, "knockback_vector", Vector2.ZERO, duration)
	animation.modulate = Color.RED
	knockback_tween.parallel().tween_property(animation, "modulate", Color.WHITE, duration)
	
	is_hurtet = true
	#$Animator.play("Time Stop")
	await get_tree().create_timer(0.3, false).timeout
	is_hurtet = false
