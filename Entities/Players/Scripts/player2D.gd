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
@export_custom(PROPERTY_HINT_NONE, "suffix:frames") var coyote_frames: int = 5
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s") var jump_velocity: float = 120.0
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s") var gravity: float = 960.0

@export_group("Movement")
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s") var speed: float = 200.0

@export_group("Dash")
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var dash_distance: float = 64.0
@export_range(0.1, 1.0, 0.05, "suffix:s") var dash_duration: float = 0.2

@export_group("Knockback")
@export_range(0.1, 0.5, 0.05, "suffix:s") var knockback_duration: float = 0.25
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var knockback_height: float = 200.0

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
@onready var hurbox: Area2D = $HutBox

var dash_timer: SceneTreeTimer

var is_die: bool = false
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
var dash_velocity: float = 0.0

func _ready() -> void:
	dash_velocity = dash_distance / dash_duration

func _process(_delta: float) -> void:
	$Label.text = str(state_machine.get_state(), " ", velocity)

func _physics_process(delta: float) -> void:
	buffer_jump.update_process()
	buffer_dash.update_process()
	state_machine.physics_update(delta)
	
	if frames > 0:
		frames -= 1
	else:
		Game.player_position = get_player_position()
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

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if is_attack:
		return
	
	if body.is_in_group("Projectiles"):
		body.queue_free()
	
	take_damage(body)

func _should_die() -> bool:
	if Game.player_life > 0:
		Game.player_life -= 1
	
	return Game.player_life <= 0

func get_player_position() -> Vector2:
	if state_machine.is_state(PlayerState.HURT):
		return Game.player_position
	
	return global_position

func die() -> void:
	if is_die:
		return
	
	is_die = true
	
	var explosion_instance: AnimatedSprite2D = explosion_scene.instantiate()
	explosion_instance.global_position = global_position
	explosion_instance.scale *= 1.5
	explosion_instance.animation_finished.connect(Game.current.dead_player.emit)
	add_sibling(explosion_instance)
	
	Game.current.shake_camera.emit(2.0, 1.0)
	Game.camera.shake(2.0, 1.0)
	
	set_process(false)
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
