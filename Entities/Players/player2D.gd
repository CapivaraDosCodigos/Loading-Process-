extends CharacterBody2D
class_name Player2D

#region
const AIR_FRICTION: float = 0.5

static var audio_jump: AudioStream = preload("uid://oirh41homqht")
static var audio_dash: AudioStream = preload("uid://lscbx1hh6oq0")

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
@onready var state_machine: StateMachineNode = $StateMachine
#endregion

var can_dash: bool = true
var dash_cooldown: bool = true
var has_dash: bool = false
var has_wall_slide: bool = false

var coyote_timer: int = 0
var wall_jump_lock: int = 0
var jump_buffer_timer: int = 0
var dash_ghost_timer: int = 0

var direction: float = 1
var fall_gravity: float = 0.0
var gravity: float = 0.0
var jump_velocity: float = 0.0
var wall_direction: float = 0.0

var knockback_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	jump_velocity = (jump_height * 2.0) / max_time_to_peak
	gravity = (jump_height * 2.0) / pow(max_time_to_peak, 2)
	fall_gravity = gravity * 2.0
	ManagerGame.camera_in_player = true
	
	has_wall_slide = Game.Item.ScalingEquipment in ManagerGame.items

func _process(_delta: float) -> void:
	remote_camera.update_position = ManagerGame.camera_in_player
	has_dash = Game.Item.Dash in ManagerGame.items

func _physics_process(_delta: float) -> void:
	if ManagerGame.paused_transition:
		if animation.is_playing():
			animation.stop()
		return
	
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

	$Label.text = state_machine.current_state.name
	
	_update_animation()
	
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = collision.get_collider()
		
		if collider is FallingPlatform2D:
			collider.has_collided_with()

func _update_animation() -> void:
	var anim: StringName = "Idle"
	
	if !is_on_floor():
		anim = "Jump"
	
	elif velocity.abs().x != 0.0:
		anim = "Run"
	
	if state_machine.is_state("Hurt"):
		anim = "Hurt"
	
	if animation.animation != anim:
		animation.play(anim)

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
	ManagerGame.camera.snake(duration, knockback_tween)
	
	if knockback_force.y == 0.0 or knockback_force.x == 0.0:
		animation.scale = Vector2(1.2, 0.8)
		var save_position: Vector2 = animation.position
		animation.position.y += 1.6
		
		knockback_tween.parallel().tween_property(animation, "scale", Vector2.ONE, duration)
		knockback_tween.parallel().tween_property(animation, "position", save_position, duration)
		
	else:
		animation.scale = Vector2(0.8, 1.2)
		var save_position: Vector2 = animation.position
		animation.position.y -= 1.6
		
		knockback_tween.parallel().tween_property(animation, "scale", Vector2.ONE, duration)
		knockback_tween.parallel().tween_property(animation, "position", save_position, duration)
	
	particles.restart()
	if sign(knockback_force.x) != 0.0:
		particles.scale.x = sign(knockback_force.x)
	else:
		particles.scale.x = -direction
	
	particles.emitting = true
	
	#current_state = State.Hurt
	state_machine.change_state("Hurt")
	await get_tree().create_timer(duration, false).timeout
	state_machine.change_state("Movement")
	#current_state = State.Movement

func _should_die() -> bool:
	if ManagerGame.player_life > 0:
		ManagerGame.player_life -= 1
		return false
		
	return true

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if state_machine.is_state("Hurt") or ManagerGame.is_paused:
		return
	
	var knockback: Vector2 = _calculate_knockback(body)
	
	take_damage(knockback)
	
	if body.is_in_group("Projectiles"):
		body.queue_free()

func _on_hurt_box_down_body_entered(body: Node2D) -> void:
	if state_machine.is_state("Hurt") or ManagerGame.is_paused:
		return
	
	if "take_damage_force" in body and not body.take_damage_force:
		return
	
	var knockback: Vector2 = _calculate_knockback(body)
	
	take_damage(knockback)
	
	if body.is_in_group("Projectiles"):
		body.queue_free()

func _on_notifier_screen_exited() -> void:
	die()

func start_dash() -> void:
	if not has_dash:
		return
	
	can_dash = false
	dash_cooldown = false
	
	state_machine.change_state("Dash")
	
	audio_movements.volume_0_100 = 100.0
	audio_movements.play_stream(audio_dash)
	
	await get_tree().create_timer(dash_duration, false).timeout
	
	state_machine.change_state("Movement")
	dash_ghost_timer = 0
	
	await get_tree().create_timer(dash_duration * 2.0, false).timeout
	
	dash_cooldown = true

func can_wall_slide() -> bool:
	if wall_jump_lock > 0 or not has_wall_slide:
		return false
	
	var touching_wall: bool = ray_right.is_colliding() or ray_left.is_colliding()
	
	return not is_on_floor() and touching_wall and velocity.y > 0

func apply_gravity(delta: float) -> void:
	if velocity.y > 0 or !Input.is_action_pressed("ui_accept"):
		velocity.y += fall_gravity * delta
	else:
		velocity.y += gravity * delta

func handle_movement() -> void:
	if not is_on_floor() and wall_jump_lock == 0:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		#velocity.x = lerp(velocity.x, 0.0, AIR_FRICTION)
	
	var direction_input: float = Input.get_axis("ui_left", "ui_right")
	
	if direction_input != 0.0 and wall_jump_lock == 0:
		direction = direction_input
		velocity.x = direction * speed
		#velocity.x = lerp(velocity.x, direction * speed, AIR_FRICTION)
		animation.flip_h = direction == -1.0

	elif wall_jump_lock == 0:
		velocity.x = 0
		#velocity.x = move_toward(velocity.x, 0, speed)

func create_ghost_sprite() -> void:
	var anim: AnimatedSprite2D = animated_shader.instantiate()
	anim.sprite_frames = animation.sprite_frames
	anim.animation = animation.animation
	anim.frame = animation.frame
	anim.flip_h = animation.flip_h
	anim.global_position = global_position
	
	add_sibling(anim)
	anim.stop()

func die() -> void:
	visible = false
	var explosion_instance: AnimatedSprite2D = explosion_scene.instantiate()
	explosion_instance.global_position = global_position
	add_sibling(explosion_instance)
	
	if ManagerGame.camera:
		ManagerGame.camera.snake(1.0, null)
	
	await explosion_instance.animation_finished
	
	queue_free()
	ManagerGame.dead_player.emit()

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
	knockback_vector = knockback_force
	
	if _should_die():
		die()
	else:
		_apply_damage(knockback_force, duration)
