extends InimigoBase2D

const MISSIL: PackedScene = preload("uid://bdlsx1t3dfvhy")
const BOMB: PackedScene = preload("uid://btsijy5vkvtar")
const BOY: PackedScene = preload("uid://clduqr40pgdxk")

@onready var missil_point: Marker2D = %MissilPoint
@onready var bomb_point: Marker2D = %BombPoint
@onready var anim_tree: AnimationTree = $AnimTree
@onready var bomb_cooldown: Timer = $BombCooldown
@onready var missil_cooldown: Timer = $MissilCooldown
@onready var state_machine: AnimationNodeStateMachinePlayback = anim_tree["parameters/playback"]
@onready var explosion: CPUParticles2D = $explosion
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var hurt_box_collision: CollisionShape2D = $hurt_box/Collision

@export var maker2d: Marker2D

var turn_count: int = 0
var missil_count: int = 0
var bomb_count: int = 0
var difficult: float = 1.0

var can_launch_missil: bool = true
var can_launch_bomb: bool = true
var is_boss_lose: bool = false
var is_fight: bool = false

func _internal_ready() -> void:
	set_physics_process(false)
	hurt_box_collision.set_deferred("disabled", true)
	take_damage_force = true

func _physics_process(delta: float) -> void:
	if Global.is_paused or is_boss_lose:
		return

	_gravity(delta)
	_flip_direction()

	var state: StringName = state_machine.get_current_node()

	match state:
		"moving":
			_handle_movement_state()

		"missil_attack":
			_handle_missil_state()

		"hide_bomb":
			_handle_bomb_state()

		"vulnerable":
			_handle_vulnerable_state()

	move_and_slide()

func _handle_movement_state() -> void:
	hurt_box_collision.set_deferred("disabled", true)
	take_damage_force = true
	
	velocity.x = lerp(velocity.x, direction.x * speed * difficult, 0.5)
	#velocity.x = direction.x * speed * difficult

	if turn_count > 5:
		anim_tree.set("parameters/conditions/can_move", false)
		anim_tree.set("parameters/conditions/time_missil", true)
		anim_tree.set("parameters/conditions/time_bomb", false)
		anim_tree.set("parameters/conditions/is_vulnerable", false)

func _handle_missil_state() -> void:
	hurt_box_collision.set_deferred("disabled", true)
	take_damage_force = true
	velocity.x = 0

	if can_launch_missil:
		_launch_missil()
		can_launch_missil = false

	if missil_count >= 5:
		missil_count = 0
		anim_tree.set("parameters/conditions/can_move", false)
		anim_tree.set("parameters/conditions/time_missil", false)
		anim_tree.set("parameters/conditions/time_bomb", true)
		anim_tree.set("parameters/conditions/is_vulnerable", false)

func _handle_bomb_state() -> void:
	hurt_box_collision.set_deferred("disabled", true)
	take_damage_force = true
	velocity.x = 0

	if can_launch_bomb:
		_throw_bomb()
		can_launch_bomb = false

	if bomb_count >= 4:
		bomb_count = 0
		anim_tree.set("parameters/conditions/can_move", false)
		anim_tree.set("parameters/conditions/time_missil", false)
		anim_tree.set("parameters/conditions/time_bomb", false)
		anim_tree.set("parameters/conditions/is_vulnerable", true)

func _handle_vulnerable_state() -> void:
	velocity.x = 0

	hurt_box_collision.set_deferred("disabled", false)
	take_damage_force = false
	
	if turn_count == 0:
		anim_tree.set("parameters/conditions/can_move", true)
		anim_tree.set("parameters/conditions/time_missil", false)
		anim_tree.set("parameters/conditions/time_bomb", false)
		anim_tree.set("parameters/conditions/is_vulnerable", false)

func _flip_direction() -> void:
	if not is_on_floor():
		return

	if wall_detector.is_colliding() or not ground_detector.is_colliding():
		direction.x *= -1.0
		wall_detector.scale.x *= -1.0
		ground_detector.scale.x *= -1.0
		sprite.scale.x *= -1.0
		turn_count += 1

func _throw_bomb() -> void:
	var bomb1: RigidBody2D = BOMB.instantiate()
	var bomb2: RigidBody2D = BOMB.instantiate()

	add_sibling(bomb1)
	add_sibling(bomb2)

	bomb1.global_position = bomb_point.global_position
	bomb2.global_position = bomb_point.global_position

	bomb1.apply_impulse(Vector2(randf_range(direction.x * 48.0, direction.x * 216.0), randf_range(-216.0, -380.0)))
	bomb2.apply_impulse(Vector2(randf_range(direction.x * 216.0, direction.x * 350.0), randf_range(-216.0, -380.0)))

	bomb_cooldown.start()
	bomb_count += 1

func _launch_missil() -> void:
	var missil: Bullet2D = MISSIL.instantiate()

	add_sibling(missil)
	missil.global_position = missil_point.global_position + Vector2(0, randf_range(-4.0, 4.0))
	missil.set_direction(int(direction.x))

	missil_cooldown.start()
	missil_count += 1

func _on_bomb_cooldown_timeout() -> void:
	can_launch_bomb = true

func _on_missil_cooldown_timeout() -> void:
	can_launch_missil = true

func _on_player_detector_body_entered(_body: Node2D) -> void:
	if is_boss_lose or is_fight:
		return
	
	is_fight = true
	set_physics_process(true)
	anim_tree.set("parameters/conditions/can_move", true)
	Global.camera_in_player = false
	Global.camera.move_position(maker2d.global_position, 0.5)

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if is_boss_lose or not is_fight or not anim_tree.get("parameters/conditions/is_vulnerable"):
		return

	if body is Player2D:
		body.velocity.y = -body.jump_velocity
		
		HP -= 1
		
		if HP <= 0:
			anim_tree.set("parameters/conditions/can_move", false)
			anim_tree.set("parameters/conditions/time_bomb", false)
			anim_tree.set("parameters/conditions/time_missil", false)
			anim_tree.set("parameters/conditions/is_vulnerable", false)
			
			state_machine.travel("dead")
			return
		
		difficult += 0.1
		turn_count = 0

func _reset_inimgo() -> void:
	if is_boss_lose:
		return

	set_physics_process(false)
	hurt_box_collision.set_deferred("disabled", true)
	take_damage_force = true

	HP = HP_base
	turn_count = 0
	missil_count = 0
	bomb_count = 0
	difficult = 1.0

	can_launch_missil = true
	can_launch_bomb = true
	is_fight = false

	state_machine.travel("enter_scene")

func lose() -> void:
	if is_boss_lose:
		return

	is_boss_lose = true

	set_physics_process(false)

	hurt_box_collision.set_deferred("disabled", true)
	take_damage_force = false

	var boss_lose: InimigoBase2D = BOY.instantiate()
	boss_lose.global_position = bomb_point.global_position + Vector2(16.0 * direction.x, 8.0)
	add_sibling(boss_lose)

	explosion.emitting = true

	Global.dead_boss.emit()
	Global.camera_in_player = true
