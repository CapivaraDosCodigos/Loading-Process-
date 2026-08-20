@tool
extends EnemyGround2D

static var fireball: PackedScene = preload("uid://b0k0ff3xtj5vt")

@onready var fireball_spawn_point: Marker2D = $FireballMarker
@onready var collision_hitbox: CollisionShape2D = $hitbox/CollisionHitbox
@onready var player_detector: RayCast2D = $PlayerDetector

enum EnemyState { PATROL, ATTACK, HURT }
var current_state: EnemyState = EnemyState.PATROL

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_gravity(delta)
	
	match(current_state):
		EnemyState.PATROL : _patrol_state()
		EnemyState.ATTACK : _attack_state()
		EnemyState.HURT : velocity = Vector2.ZERO
	
	move_and_slide()

func take_damage(_player: Player2D = null) -> void:
	current_state = EnemyState.HURT
	
	_apply_hurt_effects()
	
	if health_point > 0:
		health_point -= 1
	
	play(HURT)
	
	await get_tree().create_timer(0.3, false).timeout
	
	current_state = EnemyState.PATROL

func _attack_state() -> void:
	velocity.x = 0
	
	animation_player.play("shooting")
	if not player_detector.is_colliding():
		#await animation_player.animation_finished
		#await get_tree().create_timer(0.75, false).timeout
		current_state = EnemyState.PATROL

func _patrol_state() -> void:
	animation_player.play("running")
	
	if is_on_floor():
		if wall_detector.is_colliding():
			_flip_direction()
			
		elif !ground_detector.is_colliding():
			_flip_direction()
		
		elif player_detector.is_colliding():
			current_state = EnemyState.ATTACK
			
	_movement()

func _movement() -> void:
	if is_on_floor():
		velocity.x = direction.x * speed

func _flip_direction() -> void:
	direction.x *= -1
	
	player_detector.scale.x = direction.x * -1.0
	
	ground_detector.scale.x = direction.x * -1.0
	
	wall_detector.scale.x = direction.x * -1.0
	
	fireball_spawn_point.position.x *= -1.0
	
	collision_hitbox.position.x = direction.x * -1.0
	
	sprite.scale.x = direction.x * -1.0

func spawn_fireball() -> void:
	var new_fireball: Bullet2D = fireball.instantiate()
	new_fireball.global_position = fireball_spawn_point.global_position + Vector2(0.0 , randf_range(3.0, -3.0))
	add_sibling(new_fireball)
	
	new_fireball.direction = Vector2(sign(fireball_spawn_point.position.x), 0.0)
