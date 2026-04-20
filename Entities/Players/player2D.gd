extends CharacterBody2D
class_name Player2D

const AIR_FRICTION: float = 0.5

enum State { Movement, Wall_Slide, Wall_Jump, Dash, Hurt }

static var audio_jump: AudioStream = preload("uid://oirh41homqht")
static var audio_dash: AudioStream = preload("uid://dhxw7d62gn081")

static var explosion_scene: PackedScene = preload("uid://b0uva68sp3g41")
static var light_bulb: PackedScene = preload("uid://yxdk6ehtmywe")
static var animated_shader: PackedScene = preload("uid://dp8d0wvd7wm0j")

@export_group("Jump")
@export var coyote_frames: int = 5
@export var jump_height: float = 64.0
@export_range(0.1, 1.0, 0.05) var max_time_to_peak: float = 0.5
@export var wall_slide_force: float = 128.0

@export_group("Movement")
@export var speed: float = 200.0

@export_group("Dash")
@export var dash_distance: float = 64.0
@export_range(0.1, 1.0, 0.05) var dash_duration: float = 0.2

@export_group("Knockback")
@export_range(0.1, 0.5, 0.05) var knockback_duration: float = 0.25
@export var knockback_height: float = 200.0
@export var knockback_power: float = 20.0

@onready var animation: AnimatedSprite2D = $Animation
@onready var audio_movements: AudioPlayer2D = $AudioMovements
@onready var audio_items: AudioPlayer2D = $AudioItems
@onready var audio_sound_effect: AudioPlayer2D = $AudioSoundEffect
@onready var particles: GPUParticles2D = $Particles
@onready var ray_right: RayCast2D = $RayRight
@onready var ray_left: RayCast2D = $RayLeft
@onready var remote_camera: RemoteTransform2D = $RemoteCamera

var has_wall_climb: bool = false
var has_dash: bool = false
var can_dash: bool = true
var dash_cooldown: bool = true

var coyote_timer: int = 0
var wall_jump_lock: int = 0
var jump_buffer_timer: int = 0
var dash_ghost_timer: int = 0

var current_state: State = State.Movement

var move_direction: float = 1.0
var fall_gravity: float = 0.0
var gravity: float = 0.0
var jump_velocity: float = 0.0
var wall_direction: float = 0.0

var knockback_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	jump_velocity = (jump_height * 2.0) / max_time_to_peak
	gravity = (jump_height * 2.0) / pow(max_time_to_peak, 2)
	fall_gravity = gravity * 2.0
	Global.camera_in_player = true

func _process(_delta: float) -> void:
	remote_camera.update_position = Global.camera_in_player

func _physics_process(delta: float) -> void:
	if Global.paused_transition:
		_set_state()
		return
	
	$Label.text = State.keys().get(current_state)
	
	if wall_jump_lock > 0:
		wall_jump_lock -= 1
	
	if jump_buffer_timer > 0:
		jump_buffer_timer -= 1
	
	if dash_ghost_timer > 0:
		dash_ghost_timer -= 1
	
	if is_on_floor():
		coyote_timer = coyote_frames
		can_dash = true
	else:
		if coyote_timer > 0:
			coyote_timer -= 1
	
	match current_state:
		State.Movement:
			_handle_jump()
			_handle_movement()
			if _can_wall_slide():
				_set_player_state(State.Wall_Slide)
			
		State.Wall_Slide:
			_handle_wall_slide(delta)
			_handle_movement()
			if not _can_wall_slide():
				_set_player_state(State.Movement)
			
		State.Hurt:
			_apply_knockback()
		
		State.Wall_Jump:
			_handle_movement()
			if _can_wall_slide():
				_set_player_state(State.Movement)
		
		State.Dash:
			_apply_dash()
			if _can_wall_slide():
				_set_player_state(State.Wall_Slide)
	
	_apply_vertical_physics(delta)
	
	_set_state()
	
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = collision.get_collider()
		
		if collider is FallingPlatform2D:
			collider.has_collided_with()

func _set_player_state(new_state: State) -> void:
	if current_state == new_state or current_state == State.Hurt:
		return
	
	current_state = new_state

func _can_wall_slide() -> bool:
	if wall_jump_lock > 0:
		return false
	
	if not Global.Item.ChipClimbing in Global.items:
		return false
	
	var touching_wall: bool = ray_right.is_colliding() or ray_left.is_colliding()
	
	return not is_on_floor() and touching_wall and velocity.y > 0

func _start_dash() -> void:
	can_dash = false
	dash_cooldown = false
	_set_player_state(State.Dash)
	
	#audio_movements.volume_0_100 = 100.0
	#audio_movements.play_stream(audio_jump)
	
	_create_ghost_sprite()
	await get_tree().create_timer(dash_duration, false).timeout
	
	dash_cooldown = true
	_set_player_state(State.Movement)
	dash_ghost_timer = 0

func _handle_wall_slide(delta: float) -> void:
	velocity.y += gravity * delta
	
	wall_direction = -1.0 if ray_right.is_colliding() else 1.0
	
	if jump_buffer_timer > 0:
		velocity = Vector2(
			wall_slide_force * wall_direction,
			-jump_velocity
		)
		
		coyote_timer = 0
		jump_buffer_timer = 0
		wall_jump_lock = 8
		
		_set_player_state(State.Wall_Jump)
		audio_movements.volume_0_100 = 40.0
		audio_movements.play_stream(audio_jump)

func _handle_jump() -> void:
	if jump_buffer_timer > 0 and (is_on_floor() or coyote_timer > 0):
		velocity.y = -jump_velocity
		coyote_timer = 0
		jump_buffer_timer = 0
		audio_movements.volume_0_100 = 40
		audio_movements.play_stream(audio_jump)

func _apply_vertical_physics(delta: float) -> void:
	if current_state in [State.Dash, State.Wall_Slide]:
		return
	
	if velocity.y > 0.0 or not Input.is_action_pressed("ui_accept"):
		velocity.y += fall_gravity * delta
	else:
		velocity.y += gravity * delta

func _handle_movement() -> void:
	if not is_on_floor() and wall_jump_lock == 0:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	var direction_input: float = Input.get_axis("ui_left", "ui_right")
	
	if direction_input != 0.0 and wall_jump_lock == 0:
		move_direction = direction_input
		velocity.x = lerp(velocity.x, move_direction * speed, AIR_FRICTION)
		animation.flip_h = move_direction == -1

	elif wall_jump_lock == 0:
		velocity.x = move_toward(velocity.x, 0, speed)

func _apply_knockback() -> void:
	if knockback_vector.x != 0.0:
		velocity.x = knockback_vector.x
	
	if knockback_vector.y != 0.0:
		velocity.y = knockback_vector.y

func _apply_dash() -> void:
	velocity.x = (dash_distance / dash_duration) * move_direction
	velocity.y = 0.0
	
	if dash_ghost_timer == 0:
		_create_ghost_sprite()
		dash_ghost_timer = 3

func _create_ghost_sprite() -> void:
	var anim: AnimatedSprite2D = animated_shader.instantiate()
	anim.sprite_frames = animation.sprite_frames
	anim.animation = animation.animation
	anim.frame = animation.frame
	anim.flip_h = animation.flip_h
	anim.global_position = global_position
	
	add_sibling(anim)
	anim.stop()

func _unhandled_input(event: InputEvent) -> void:
	if current_state == State.Hurt:
		return
	
	if event.is_action_pressed("ui_accept"):
		jump_buffer_timer = 6
	
	if event.is_action_pressed("Ability") and current_state != State.Dash and can_dash and dash_cooldown:
		_start_dash()
		
		if not Global.is_paused and Global.Item.Lampada in Global.items:
			var light: RigidBody2D = light_bulb.instantiate()
			light.global_position = global_position
			add_sibling(light)
			light.apply_impulse(Vector2(randf_range(-128.0, 128.0), randf_range(-216.0, -380.0)))
			Global.time_stop_event()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if current_state == State.Hurt or Global.is_paused:
		return
	
	var knockback: Vector2 = _calculate_knockback(body)
	
	take_damage(knockback)
	
	if body.is_in_group("Projectiles"):
		body.queue_free()

func _on_hurt_box_down_body_entered(body: Node2D) -> void:
	if current_state == State.Hurt or Global.is_paused:
		return
	
	if "take_damage_force" in body and not body.take_damage_force:
		return
	
	var knockback: Vector2 = _calculate_knockback(body)
	
	take_damage(knockback)
	
	if body.is_in_group("Projectiles"):
		body.queue_free()

func _on_notifier_screen_exited() -> void:
	queue_free()
	Global.dead_player.emit()

func _set_state() -> void:
	var state: StringName = "Idle"
	
	if !is_on_floor():
		state = "Jump"
	
	elif velocity.abs().x != 0.0:
		state = "Run"
	
	if current_state == State.Hurt:
		state = "Hurt"
	
	if animation.animation != state:
		animation.play(state)

func _calculate_knockback(body: Node2D) -> Vector2:
	var y_force: float = -knockback_height if body.global_position.y >= global_position.y else 0.0
	
	var knockback: Vector2 = Vector2((global_position.x - body.global_position.x) * knockback_power,
	y_force)
	
	return knockback

func _set_shader_blink_intensity(new_value: float) -> void:
	animation.material.set("shader_parameter/blink_intensity", new_value)

func _apply_damage(knockback_force: Vector2, duration: float = knockback_duration) -> void:
	knockback_vector = knockback_force
	var knockback_tween: Tween = create_tween()
	knockback_tween.parallel().tween_property(self, "knockback_vector", Vector2.ZERO, duration)
	
	knockback_tween.parallel().tween_method(_set_shader_blink_intensity, 1.0, 0.0, duration)
	Global.camera.snake(duration, knockback_tween)
	
	particles.restart()
	if sign(knockback_force.x) != 0.0:
		particles.scale.x =  sign(knockback_force.x)
	else:
		particles.scale.x = -move_direction
	
	particles.emitting = true
	
	current_state = State.Hurt
	await get_tree().create_timer(duration, false).timeout
	current_state = State.Movement

func _should_die() -> bool:
	if Global.player_life > 0:
		Global.player_life -= 1
		return false
		
	return true

func _die() -> void:
	current_state = State.Hurt
	visible = false
	var explosion_instance: AnimatedSprite2D = explosion_scene.instantiate()
	explosion_instance.global_position = global_position
	add_sibling(explosion_instance)
	
	Global.camera.snake(1.0, null)
	await explosion_instance.animation_finished
	
	queue_free()
	Global.dead_player.emit()

func play_audio(type: StringName, stream: AudioStream, volume: float = 100.0, loop: bool = false, pitch: bool = true) -> void:
	var audio: AudioPlayer2D
	
	if type == "SoundEffect":
		audio = audio_sound_effect
		
	elif type == "Items":
		audio = audio_items
		
	else:
		print("oi")
		return
	
	audio.volume_0_100 = volume
	audio.loop = loop
	audio.pitch_random = pitch
	
	audio.play_stream(stream)

func follow_camera(camera: Camera2D) -> void:
	var camera_path: NodePath = camera.get_path()
	remote_camera.remote_path = camera_path

func take_damage(knockback_force: Vector2, duration: float = 0.25) -> void:
	if current_state == State.Hurt:
		return
	
	if _should_die():
		_die()
	else:
		_apply_damage(knockback_force, duration)
