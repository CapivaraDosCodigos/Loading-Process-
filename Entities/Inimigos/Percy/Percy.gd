extends InimigoBase2D

static var fireball: PackedScene = preload("uid://b0k0ff3xtj5vt")

@onready var fireball_spawn_point: Marker2D = $FireballMarker
@onready var collision_hitbox: CollisionShape2D = $hitbox/CollisionHitbox
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector

enum EnemyState { PATROL, ATTACK, HURT }
var current_state: EnemyState = EnemyState.PATROL

func _stop() -> void:
	set_physics_process(false)
	animation_player.pause()

func _play() -> void:
	set_physics_process(true)

func _internal_ready() -> void:
	direction.x = 1.0

func _physics_process(delta: float) -> void:
	_gravity(delta)
	
	match(current_state):
		EnemyState.PATROL : _patrol_state()
		EnemyState.ATTACK : _attack_state()

func _attack_state() -> void:
	animation_player.play("shooting")
	if not player_detector.is_colliding():
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

func take_damage(player: Player2D = null) -> void:
	current_state = EnemyState.HURT
	
	if player: player.velocity.y = -player.jump_velocity
	
	velocity = Vector2.ZERO
	var knockback_tween: Tween = create_tween()
	sprite.modulate = Color.RED
	knockback_tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)
	animation_player.play("Hurt")
	
	if HP > 0:
		HP -= 1
	
	await get_tree().create_timer(0.3, false).timeout
	current_state = EnemyState.PATROL

func spawn_fireball() -> void:
	var new_fireball: Bullet2D = fireball.instantiate()
	new_fireball.global_position = fireball_spawn_point.global_position + Vector2(0.0 , randf_range(3.0, -3.0))
	add_sibling(new_fireball)
	
	if sign(fireball_spawn_point.position.x) == 1:
		new_fireball.set_direction(1)
	else:
		new_fireball.set_direction(-1)

func _flip_direction() -> void:
	direction.x *= -1
	player_detector.scale.x *= -1.0
	ground_detector.scale.x *= -1.0
	wall_detector.scale.x *= -1.0
	fireball_spawn_point.position.x *= -1.0
	collision_hitbox.position.x *= -1.0
	sprite.flip_h = direction.x == -1.0

func _on_animation_player_finished(animated_name: StringName) -> void:
	if animated_name == "Hurt":
		if HP <= 0:
			Global.score += score
			create_coins()
			queue_free()
