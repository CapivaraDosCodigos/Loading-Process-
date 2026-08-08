extends CharacterBody2D
class_name Player2D

const AIR_FRICTION: float = 0.5

static var audio_jump: AudioStream = preload("uid://diu3u0xv087kx")
static var audio_dash: AudioStream = preload("uid://lscbx1hh6oq0")
static var audio_hurt: AudioStream = preload("uid://dbs0jxxu6x1rp")

static var explosion_scene: PackedScene = preload("uid://b0uva68sp3g41")
static var animated_shader: PackedScene = preload("uid://dp8d0wvd7wm0j")

static var buffer_jump: InputBuffer = InputBuffer.new("ui_accept", 5)
static var buffer_dash: InputBuffer = InputBuffer.new("Dash", 5)

@export_group("Jump")
@export var coyote_frames: int = 5
@export var jump_height: float = 64.0
@export_range(0.1, 1.0, 0.01) var max_time_to_peak: float = 0.5

@export_group("Movement")
@export var speed: float = 200.0

@export_group("Dash")
@export var dash_distance: float = 64.0
@export_range(0.1, 1.0, 0.05) var dash_duration: float = 0.2

@export_group("Knockback")
@export_range(0.1, 0.5, 0.05) var knockback_duration: float = 0.25
@export var knockback_height: float = 200.0

@export_category("DEBUG")
@export var immortal: bool = false

@onready var animation: AnimatedSprite2D = $Animation
@onready var collision: CollisionShape2D = $Collision
@onready var particles: Particles2D = $Particles
@onready var ray_right: RayCast2D = $RayRight
@onready var ray_left: RayCast2D = $RayLeft
@onready var ray_up: RayCast2D = $RayUp
@onready var ray_down: RayCast2D = $RayDown
@onready var state_machine: StateMachine = $StateMachine

var dash_timer: SceneTreeTimer

var is_attack: bool = false
var can_dash: bool = true
var dash_cooldown: bool = true

var frames: int = 0
var coyote_timer: int = 0

var direction: float = 1.0:
	set(value):
		value = sign(value)
		if value == 0.0:
			return
		direction = value

# Definidas no ready
var fall_gravity: float = 0.0
var gravity: float = 0.0
var jump_velocity: float = 0.0
var dash_velocity: float = 0.0

func _init() -> void:
	jump_velocity = (jump_height * 2.0) / max_time_to_peak
	gravity = (jump_height * 2.0) / pow(max_time_to_peak, 2)
	fall_gravity = gravity * 2.0
	dash_velocity = dash_distance / dash_duration

func _process(_delta: float) -> void:
	if dash_timer:
		$Label.text = str(state_machine.get_state(), " ", velocity)

func _physics_process(delta: float) -> void:
	buffer_jump.update_process()
	buffer_dash.update_process()
	state_machine.physics_update(delta)
	
	if frames > 0:
		frames -= 1
	else:
		ManagerGame.player_position = get_player_position()
		frames = 30
	
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

func _should_die() -> bool:
	if ManagerGame.player_life > 0:
		ManagerGame.player_life -= 1
	
	return ManagerGame.player_life <= 0

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if is_attack:
		return
	
	if body.is_in_group("Projectiles"):
		body.queue_free()
	
	take_damage(body)

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

func get_player_position() -> Vector2:
	if state_machine.is_state(PlayerState.HURT):
		return ManagerGame.player_position
	
	return global_position

func use_skills() -> void:
	pass

func can_wall_slide() -> bool:
	var touching_wall: bool = ray_right.is_colliding() or ray_left.is_colliding()
	
	return not is_on_floor() and touching_wall and velocity.y > 0

func die() -> void:
	var explosion_instance: AnimatedSprite2D = explosion_scene.instantiate()
	explosion_instance.global_position = global_position
	explosion_instance.scale *= 1.5
	explosion_instance.animation_finished.connect(ManagerGame.dead_player.emit)
	add_sibling(explosion_instance)
	
	set_physics_process(false)
	queue_free()

func take_damage(body: CollisionObject2D) -> void:
	if body is Enemy2D:
		body.apply_stun()
	
	if state_machine.is_state(PlayerState.HURT):
		return
	
	if _should_die() and not immortal:
		die()
	else:
		var data: Dictionary[String, Variant] = {"body_pos": body.global_position}
		state_machine.transition_to_next_state(PlayerState.HURT, data)
