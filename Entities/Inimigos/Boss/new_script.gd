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
var player_hit: bool = false
var player_enter: bool = false
var is_boss_lose: bool = false

func _internal_ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	_gravity(delta)
	_flip_direction()
	
	match state_machine.get_current_node():
		"moving":
			hurt_box_collision.set_deferred("disabled", true)
			take_damage_force = true
			_movement()
		
		"missil_attack":
			velocity.x = 0.0
			await get_tree().create_timer(2.0, false).timeout
			if can_launch_missil:
				_launch_missil()
				can_launch_missil = false
		
		"hide_bomb":
			velocity.x = 0.0
			await get_tree().create_timer(3.0, false).timeout
			if can_launch_bomb:
				_throw_bomb()
				can_launch_bomb = false
		
		"vulnerable":
			velocity.x = 0.0
			can_launch_bomb = false
			can_launch_missil = false
			await get_tree().create_timer(3.0, false).timeout
			player_hit = false
			hurt_box_collision.set_deferred("disabled", false)
			take_damage_force = false

	if turn_count <= 4:
		anim_tree.set("parameters/conditions/can_move", true)
		anim_tree.set("parameters/conditions/time_missil", false)
	
	elif missil_count >= 4:
		anim_tree.set("parameters/conditions/time_bomb", true)
		missil_count = 0
	
	elif bomb_count >= 3:
		anim_tree.set("parameters/conditions/is_vulnerable", true)
		bomb_count = 0
	
	else:
		anim_tree.set("parameters/conditions/can_move", false)
		anim_tree.set("parameters/conditions/is_vulnerable", false)
		anim_tree.set("parameters/conditions/time_bomb", false)
		anim_tree.set("parameters/conditions/time_missil", true)
	
	move_and_slide()

func _flip_direction() -> void:
	if not is_on_floor():
		return
	
	if wall_detector.is_colliding() or not ground_detector.is_colliding():
		direction.x *= -1.0
		wall_detector.scale.x *= -1.0
		ground_detector.scale.x *= -1.0
		sprite.scale.x *= -1.0
		turn_count += 1

func _stop() -> void:
	set_physics_process(false)

func _play() -> void:
	set_physics_process(true)

func _movement() -> void:
	if is_on_floor():
		velocity.x = direction.x * speed * difficult
	
	move_and_slide()

func _throw_bomb() -> void:
	if bomb_count <= 3:
		var bomb_instance: RigidBody2D = BOMB.instantiate()
		var bomb_instance2: RigidBody2D = BOMB.instantiate()
		add_sibling(bomb_instance)
		add_sibling(bomb_instance2)
		bomb_instance.global_position = bomb_point.global_position
		bomb_instance2.global_position = bomb_point.global_position
		bomb_instance.apply_impulse(Vector2(randf_range(direction.x * 48.0, direction.x * 216.0), randf_range(-216.0, -380.0)))
		bomb_instance2.apply_impulse(Vector2(randf_range(direction.x * 216.0, direction.x * 350.0), randf_range(-216.0, -380.0)))
		bomb_cooldown.start()
		bomb_count += 1

func _launch_missil() -> void:
	if missil_count <= 4:
		var missil_instance: Bullet2D = MISSIL.instantiate()
		add_sibling(missil_instance)
		missil_instance.global_position = missil_point.global_position + Vector2(0.0 , randf_range(4.0, -4.0))
		missil_instance.set_direction(int(direction.x))
		missil_cooldown.start()
		missil_count += 1

func _on_bomb_cooldown_timeout() -> void:
	can_launch_bomb = true

func _on_missil_cooldown_timeout() -> void:
	can_launch_missil = true

func _on_player_detector_body_entered(_body: Node2D) -> void:
	set_physics_process(not player_enter)
	ManagerGame.camera_in_player = is_boss_lose
	ManagerGame.camera.move_position(maker2d.global_position, 0.5)

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body is Player2D:
		body.velocity.y = -body.jump_velocity * 1.5
		HP -= 1
		difficult += 0.1
		player_hit = true
		turn_count = 0
		if HP <= 0:
			state_machine.travel("dead")

func _reset_inimgo() -> void:
	if is_boss_lose:
		return
	
	set_physics_process(false)
	HP = HP_base
	turn_count = 0
	missil_count = 0
	bomb_count = 0
	difficult = 1.0

	can_launch_missil = true
	can_launch_bomb = true
	player_hit = false
	player_enter = false
	
	state_machine.travel("enter_scene")

func lose() -> void:
	hurt_box_collision.set_deferred("disabled", true)
	take_damage_force = false
	set_physics_process(false)
	
	var boss_lose: InimigoBase2D = BOY.instantiate()
	boss_lose.global_position = bomb_point.global_position + Vector2(16.0 * direction.x, 8.0)
	add_sibling(boss_lose)
	
	explosion.emitting = true
	is_boss_lose = true
	player_enter = true
	ManagerGame.dead_boss.emit()
	ManagerGame.camera_in_player = true
