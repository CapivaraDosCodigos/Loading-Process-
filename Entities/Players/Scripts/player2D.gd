extends CharacterBody2D
class_name Player2D

@export var immortal: bool = false

const selection: PackedScene = preload("res://Entities/Players/area_seletion.tscn")

#region

const AIR_FRICTION: float = 0.5

static var audio_jump: AudioStream = preload("uid://diu3u0xv087kx")
static var audio_dash: AudioStream = preload("uid://lscbx1hh6oq0")
static var audio_hurt: AudioStream = preload("uid://dbs0jxxu6x1rp")

static var explosion_scene: PackedScene = preload("uid://b0uva68sp3g41")
static var light_bulb: PackedScene = preload("uid://yxdk6ehtmywe")
static var animated_shader: PackedScene = preload("uid://dp8d0wvd7wm0j")

@export_group("Jump")
@export var buffer_jump: InputBuffer
@export var coyote_frames: int = 5
@export var jump_height: float = 64.0
@export_range(0.1, 1.0, 0.01) var max_time_to_peak: float = 0.5
@export var wall_slide_force: float = 128.0

@export_group("Movement")
@export var speed: float = 200.0

@export_group("Dash")
@export var buffer_dash: InputBuffer
@export var dash_distance: float = 64.0
@export_range(0.1, 1.0, 0.05) var dash_duration: float = 0.2

@export_group("Knockback")
@export_range(0.1, 0.5, 0.05) var knockback_duration: float = 0.25
@export var knockback_height: float = 200.0
@export var knockback_power: float = 20.0

@onready var animation: AnimatedSprite2D = $Animation
@onready var collision: CollisionShape2D = $Collision
@onready var particles: GPUParticles2D = $Particles
@onready var ray_right: RayCast2D = $RayRight
@onready var ray_left: RayCast2D = $RayLeft
@onready var state_machine: StateMachine = $StateMachine
#endregion

var can_dash: bool = true
var dash_cooldown: bool = true
var has_dash: bool = false
var has_wall_slide: bool = false

var coyote_timer: int = 0
var wall_jump_lock: int = 0
var dash_ghost_timer: int = 0

var direction: float = 1
var fall_gravity: float = 0.0
var gravity: float = 0.0
var jump_velocity: float = 0.0
var wall_direction: float = 0.0

var knockback_vector: Vector2 = Vector2.ZERO

var dash_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	
	jump_velocity = (jump_height * 2.0) / max_time_to_peak
	gravity = (jump_height * 2.0) / pow(max_time_to_peak, 2)
	fall_gravity = gravity * 2.0
	
	has_wall_slide = Game.Item.ScalingEquipment in ManagerGame.items
	has_dash = Game.Item.Dash in ManagerGame.items

func _process(_delta: float) -> void:
	has_dash = Game.Item.Dash in ManagerGame.items

func _physics_process(_delta: float) -> void:
	if ManagerGame.paused_transition:
		if animation.is_playing():
			animation.stop()
		return
	
	if ManagerGame.camera and ManagerGame.camera.transitioning:
		if animation.is_playing():
			animation.stop()
		can_dash = true
		return
	
	buffer_jump.update_process()
	buffer_dash.update_process()
	
	if wall_jump_lock > 0:
		wall_jump_lock -= 1
	
	if dash_ghost_timer > 0:
		dash_ghost_timer -= 1
	
	if is_on_floor():
		coyote_timer = coyote_frames
	else:
		if coyote_timer > 0:
			coyote_timer -= 1
	
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var icollision: KinematicCollision2D = get_slide_collision(i)
		var icollider: Object = icollision.get_collider()
		
		if icollider is FallingPlatform2D:
			icollider.has_collided_with()
	
	#if global_position.y > 536.0:
		#get_tree().reload_current_scene()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interect"):
		_invocaion()

func _invocaion() -> void:
	var copiar_load: PackedScene = load("uid://c6dwuxtm4i3rx")
	var copiar_ins: CopyBody2D = copiar_load.instantiate()
	copiar_ins.global_position = global_position - Vector2(0.0, 16.0)
	add_sibling(copiar_ins)

func _set_shader_blink_intensity(new_value: float) -> void:
	animation.material.set("shader_parameter/blink_intensity", new_value)

func _apply_damage(knockback_force: Vector2, duration: float = knockback_duration) -> void:
	state_machine.transition_to_next_state("Hurt")
	
	AudioManager.set_loop(AudioGame.PLAYER_SFX_1, false).set_pitch_random(true, 0.8, 1.2)
	AudioManager.play(AudioGame.PLAYER_SFX_1, audio_hurt, 90.0)
	
	knockback_vector = knockback_force
	var knockback_tween: Tween = create_tween()
	var hurt_direction: float = direction
	
	knockback_tween.parallel().tween_property(self, "knockback_vector", Vector2.ZERO, duration)
	
	knockback_tween.parallel().tween_method(_set_shader_blink_intensity, 1.0, 0.0, duration)
	ManagerGame.camera.shake(2.0, duration)
	
	if knockback_force.y == 0.0 or knockback_force.x == 0.0:
		animation.scale = Vector2(1.2 * hurt_direction, 0.8)
		var save_position: Vector2 = animation.position
		animation.position.y += 1.6
		
		knockback_tween.parallel().tween_property(animation, "scale", Vector2(hurt_direction, 1.0), duration)
		knockback_tween.parallel().tween_property(animation, "position", save_position, duration)
		
	else:
		animation.scale = Vector2(0.8 * hurt_direction, 1.2)
		var save_position: Vector2 = animation.position
		animation.position.y -= 1.6
		
		knockback_tween.parallel().tween_property(animation, "scale", Vector2(hurt_direction, 1.0), duration)
		knockback_tween.parallel().tween_property(animation, "position", save_position, duration)
	
	particles.restart()
	
	if sign(knockback_force.x) != 0.0:
		particles.scale.x = sign(knockback_force.x)
	else:
		particles.scale.x = -direction
	
	if sign(knockback_force.y) != 0.0:
		particles.scale.y = -sign(knockback_force.y) 
	else:
		particles.scale.y = 1.0
	
	particles.emitting = true
	
	#current_state = State.Hurt
	await get_tree().create_timer(duration, false).timeout
	
	state_machine.transition_to_next_state("Jump")
	#current_state = State.Movement

func _should_die() -> bool:
	if ManagerGame.player_life > 0:
		ManagerGame.player_life -= 1
	
	return ManagerGame.player_life <= 0

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if ManagerGame.is_paused:
		return
	
	var knockback: Vector2 = MathGame.calculate_knockback(global_position, body.global_position, knockback_height,knockback_power)
	
	if body.is_in_group("Projectiles"):
		body.queue_free()
		
	take_damage(knockback)

func _on_hurt_box_down_body_entered(body: Node2D) -> void:
	if ManagerGame.is_paused:
		return
	
	if "take_damage_force" in body and not body.take_damage_force:
		return
		
	var knockback: Vector2 = MathGame.calculate_knockback(global_position, body.global_position, knockback_height,knockback_power)
	
	if body.is_in_group("Projectiles"):
		body.queue_free()
	
	take_damage(knockback)

func _on_notifier_screen_exited() -> void:
	if ManagerGame.area_camera_inclusive:
		ManagerGame.area_camera_inclusive = null
		die()
		return
	
	var died: bool = true
	if ManagerGame.camera:
		for area: CameraArea2D in ManagerGame.camera.all_areas:
			if area.contains_point(global_position):
				died = false
				
	if died:
		die()

func _exit_tree() -> void:
	ManagerGame.area_camera_inclusive = null

func use_skills() -> void:
	if Game.Item.Lampada in ManagerGame.items:
		if not ManagerGame.is_paused and can_dash:
			ManagerGame.time_stop_event()

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
		velocity.x = 0.0
		#velocity.x = move_toward(velocity.x, 0.0, speed)
	
	var direction_input: float = Input.get_axis("ui_left", "ui_right")
	
	if direction_input != 0.0 and wall_jump_lock == 0:
	#if direction_input != 0.0:
		direction = direction_input
		velocity.x = direction * speed
		#velocity.x = lerp(velocity.x, direction * speed, AIR_FRICTION)
		animation.scale.x = direction 
		
	elif wall_jump_lock == 0:
		velocity.x = 0.0
		#velocity.x = move_toward(velocity.x, 0.0, speed)

func create_ghost_sprite() -> void:
	var anim: AnimatedSprite2D = animated_shader.instantiate()
	anim.sprite_frames = animation.sprite_frames
	anim.animation = animation.animation
	anim.frame = animation.frame
	anim.flip_h = animation.flip_h
	anim.global_position = global_position
	anim.scale = animation.scale
	
	add_sibling(anim)
	anim.stop()

func die() -> void:
	var explosion_instance: AnimatedSprite2D = explosion_scene.instantiate()
	explosion_instance.global_position = global_position
	explosion_instance.scale *= 1.5
	explosion_instance.animation_finished.connect(ManagerGame.dead_player.emit)
	add_sibling(explosion_instance)
	
	ManagerGame.camera.shake(2.0, 1.0)
	
	queue_free()

func take_damage(knockback_force: Vector2, duration: float = 0.25) -> void:
	if state_machine.is_state("Hurt"):
		return
	
	knockback_vector = knockback_force
	
	if _should_die() and not immortal:
		die()
	else:
		_apply_damage(knockback_force, duration)
