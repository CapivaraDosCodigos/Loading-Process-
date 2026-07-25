extends CharacterBody2D
class_name Player2D

const AIR_FRICTION: float = 0.5
const COLORS_DIR: Dictionary[COLORS, ShaderMaterial] = {
	COLORS.YELLOW: preload("uid://bolhwx21wdob3"),
	COLORS.RED: preload("uid://bpo8tdats55qx"),
	COLORS.GRAY: preload("uid://dqrn6lus63i50"), 
	COLORS.NULL: null }
enum COLORS { YELLOW, RED, GRAY, NULL }

static var audio_jump: AudioStream = preload("uid://diu3u0xv087kx")
static var audio_dash: AudioStream = preload("uid://lscbx1hh6oq0")
static var audio_hurt: AudioStream = preload("uid://dbs0jxxu6x1rp")

static var explosion_scene: PackedScene = preload("uid://b0uva68sp3g41")
static var light_bulb: PackedScene = preload("uid://yxdk6ehtmywe")
static var animated_shader: PackedScene = preload("uid://dp8d0wvd7wm0j")

static var buffer_jump: InputBuffer = InputBuffer.new("ui_accept", 5)
static var buffer_dash: InputBuffer = InputBuffer.new("Dash", 5)

@export var color: COLORS = COLORS.YELLOW

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
@export var knockback_power: float = 20.0

@export_category("DEBUG")
@export var immortal: bool = false

@onready var animation: AnimatedSprite2D = $Animation
@onready var collision: CollisionShape2D = $Collision
@onready var particles: Particles2D = $Particles
@onready var ray_right: RayCast2D = $RayRight
@onready var ray_left: RayCast2D = $RayLeft
@onready var state_machine: StateMachine = $StateMachine

var can_dash: bool = true
var dash_cooldown: bool = true

var coyote_timer: int = 0
var dash_ghost_timer: int = 0

var direction: float = 1.0

var knockback_vector: Vector2 = Vector2.ZERO

# Definidas no ready
var fall_gravity: float = 0.0
var gravity: float = 0.0
var jump_velocity: float = 0.0
var dash_velocity: float = 0.0
var has_dash: bool = false
var has_wall_slide: bool = false

func _ready() -> void:
	jump_velocity = (jump_height * 2.0) / max_time_to_peak
	gravity = (jump_height * 2.0) / pow(max_time_to_peak, 2)
	fall_gravity = gravity * 2.0
	dash_velocity = dash_distance / dash_duration
	
	has_wall_slide = Game.Item.ScalingEquipment in ManagerGame.items
	has_dash = Game.Item.Dash in ManagerGame.items
	
	animation.material = COLORS_DIR[color]

func _process(_delta: float) -> void:
	has_dash = Game.Item.Dash in ManagerGame.items
	$Label.text = str(state_machine.get_state()) + " " + str(velocity)
	
	animation.material = COLORS_DIR[color]

func _physics_process(delta: float) -> void:
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
	state_machine.physics_update(delta)
	
	if is_on_floor():
		coyote_timer = coyote_frames
	else:
		if coyote_timer > 0:
			coyote_timer -= 1
	
	if dash_ghost_timer > 0:
		dash_ghost_timer -= 1
	else:
		create_ghost_sprite()
		dash_ghost_timer = 2
	
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
	if ManagerGame.is_paused:
		return
	
	if body.is_in_group("Projectiles"):
		body.queue_free()
	
	take_damage(body)

func _on_hurt_box_down_body_entered(body: Node2D) -> void:
	if ManagerGame.is_paused:
		return
	
	if not body.get("take_damage_force"):
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

func _exit_tree() -> void:
	ManagerGame.area_camera_inclusive = null

func use_skills() -> void:
	if Game.Item.Lampada in ManagerGame.items:
		if not ManagerGame.is_paused and can_dash:
			ManagerGame.time_stop_event()

func can_wall_slide() -> bool:
	if not has_wall_slide:
		return false
	
	var touching_wall: bool = ray_right.is_colliding() or ray_left.is_colliding()
	
	return not is_on_floor() and touching_wall and velocity.y > 0

func create_ghost_sprite() -> void:
	if velocity.abs().x <+ speed+1 and velocity.abs().y <= speed+1:
		return
		
	var anim: AnimatedSpriteShader2D = animated_shader.instantiate()
	anim.sprite_frames = animation.sprite_frames
	anim.animation = animation.animation
	anim.frame = animation.frame
	anim.flip_h = animation.flip_h
	anim.global_position = global_position
	anim.scale = animation.scale
	#anim.set_shader(animation.material)
	
	add_sibling(anim)
	anim.stop()

func die() -> void:
	var explosion_instance: AnimatedSprite2D = explosion_scene.instantiate()
	explosion_instance.global_position = global_position
	explosion_instance.scale *= 1.5
	explosion_instance.animation_finished.connect(ManagerGame.dead_player.emit)
	add_sibling(explosion_instance)
	
	set_physics_process(false)
	ManagerGame.shake_camera.emit(2.0, 1.0)
	queue_free()

func take_damage(body: CollisionObject2D) -> void:
	if body is InimigoBase2D:
		body.apply_stun()
	
	if state_machine.is_state(PlayerState.HURT):
		return
	
	if _should_die() and not immortal:
		die()
	else:
		var data: Dictionary[String, Variant] = {"body_pos": body.global_position}
		state_machine.transition_to_next_state(PlayerState.HURT, data)
