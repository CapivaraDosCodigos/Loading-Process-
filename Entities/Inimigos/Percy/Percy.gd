extends InimigoBase2D

const FIREBALL: PackedScene = preload("uid://b0k0ff3xtj5vt")

@onready var sprite: Sprite2D = $Sprite
@onready var anim: AnimationPlayer = $anim
@onready var fireball_spawn_point: Marker2D = $FireballMarker
@onready var collision_head: CollisionShape2D = $CollisionHead
@onready var collision_hitbox: CollisionShape2D = $hitbox/CollisionHitbox
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector_front: RayCast2D = $PlayerDetectorFront
@onready var player_detector_back: RayCast2D = $PlayerDetectorBack

@export var health_point: int = 6

enum EnemyState { PATROL, ATTACK, HURT }
var current_state: EnemyState = EnemyState.PATROL

func _ready() -> void:
	direction.x = 1.0

func _physics_process(delta: float) -> void:
	_gravity(delta)
	
	match(current_state):
		EnemyState.PATROL : _patrol_state()
		EnemyState.ATTACK : _attack_state()

func _attack_state() -> void:
	anim.play("shooting")
	if  not player_detector_front.is_colliding():
		current_state = EnemyState.PATROL

func _patrol_state() -> void:
	anim.play("running")
	
	if wall_detector.is_colliding():
		_flip_direction()
		
	elif !ground_detector.is_colliding():
		_flip_direction()
		
	#elif player_detector_back.is_colliding():
		#_flip_direction()
		
	elif player_detector_front.is_colliding():
		current_state = EnemyState.ATTACK
		
	_movement()

func take_damage(player: Player2D = null) -> void:
	if player:
		player.velocity.y = -player.jump_velocity
	
	velocity = Vector2.ZERO
	var knockback_tween: Tween = create_tween()
	sprite.modulate = Color.RED
	knockback_tween.tween_property(sprite, "modulate", Color.WHITE, 0.25)
	anim.play("hurt")
	
	if health_point > 0:
		health_point -= 1
	
	await get_tree().create_timer(0.3, false).timeout
	current_state = EnemyState.PATROL

func spawn_fireball() -> void:
	var new_fireball: Bullet2D = FIREBALL.instantiate()
	new_fireball.global_position = fireball_spawn_point.global_position
	add_sibling(new_fireball)
	
	if sign(fireball_spawn_point.position.x) == 1:
		new_fireball.set_direction(1)
	else:
		new_fireball.set_direction(-1)

func _flip_direction() -> void:
	direction.x *= -1
	player_detector_front.scale.x *= -1.0
	ground_detector.scale.x *= -1.0
	wall_detector.scale.x *= -1.0
	player_detector_back.scale *= -1.0
	fireball_spawn_point.position.x *= -1.0
	collision_hitbox.position.x *= -1.0
	collision_head.position.x *= -1.0
	sprite.flip_h = direction.x == -1.0

func _on_hitbox_body_entered(_body: Node2D) -> void:
	current_state = EnemyState.HURT

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Hurt":
		if health_point <= 0:
			Global.score += score
			queue_free()
