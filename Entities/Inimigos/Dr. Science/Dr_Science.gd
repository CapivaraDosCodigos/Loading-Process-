extends InimigoGround2D

@onready var ground_detector: RayCast2D = $GroundDetector
@onready var maker_bullet: Marker2D = $Marker2D
@onready var position_maker: Vector2 = $Marker2D.position

@export var shooting_interval: float = 2.0
@export var bullet_scene: PackedScene
@export var life: int = 3
@export var JUMP_FORCE: float = -300.0

var shooting_time: float = 0.0

#func _stop() -> void:
	#set_physics_process(false)
	#animated.pause()
#
#func _play() -> void:
	#set_physics_process(true)
	#animated.play()

#func _internal_ready() -> void:
	#direction = scale.y * -1.0
	#scale.y = 1.0
	#rotation = 0.0
	#wall_detector.scale.x = direction * -1.0
	#animated.flip_h = direction == 1.0

func _physics_process(delta: float) -> void:
	_gravity(delta)
	_set_state()
	
	if not Global.player:
		return
	
	#if is_hurtet:
		#move_and_slide()
		#return
	
	direction = (Global.player.global_position - global_position).normalized()
	
	_movement()
	_flip_direction()
	
	if is_hurtet:
		return
	
	shooting_time -= delta
	if shooting_time <= 0:
		shoot()
		shooting_time = shooting_interval

func _movement() -> void:
	if is_on_floor():
		#if Input.is_action_just_pressed("ui_accept"):
			#velocity.y = JUMP_FORCE
			
		if wall_detector.is_colliding():
			velocity.y = JUMP_FORCE
			
		elif not ground_detector.is_colliding():
			velocity.y = JUMP_FORCE
	
	var distance: float = abs(global_position.x - Global.player.global_position.x)
	if distance > 48.0:
		velocity.x = direction.x * speed
		
	elif distance < 48.0 and distance > 32:
		velocity.x = 0.0
	else:
		velocity.x = direction.x * speed * -1.0
	
	move_and_slide()

func _flip_direction() -> void:
	if velocity.x > 0.0:
		animated.flip_h = false
		maker_bullet.position.x = position_maker.x
		wall_detector.scale.x = 1.0
		
	elif velocity.x < 0.0:
		animated.flip_h = true
		maker_bullet.position.x = position_maker.x * -1.0
		wall_detector.scale.x = -1.0
	
	else:
		if direction.x > 0:
			animated.flip_h = false
			maker_bullet.position.x = position_maker.x
			wall_detector.scale.x = 1.0
			
		elif direction.x < 0:
			animated.flip_h = true
			maker_bullet.position.x = position_maker.x * -1.0
			wall_detector.scale.x = -1.0

func _set_state() -> void:
	var state: StringName = "Idle_Gun"
	
	if !is_on_floor():
		state = "Jump_Gun"
		
	elif velocity.x != 0.0:
		state = "Run_Gun"
	
	if is_hurtet:
		return
	
	if animated.animation != state:
		animated.play(state)

func _on_animated_animation_finished() -> void:
	if animated.animation == "Hurt":
		if life <= 0:
			Global.score += score
			queue_free()
		is_hurtet = false

func shoot() -> void:
	var bullet_instantiate: Bullet2D = bullet_scene.instantiate()
	bullet_instantiate.global_position = maker_bullet.global_position
	add_sibling(bullet_instantiate)
	if animated.flip_h:
		bullet_instantiate.set_direction(-1)
	else:
		bullet_instantiate.set_direction(1)

func take_damage(player: Player2D = null) -> void:
	if is_hurtet:
		return
	
	if player:
		player.velocity.y = -player.jump_velocity
	
	if life > 0:
		life -= 1
	
	#velocity.x = direction.x * JUMP_FORCE
	
	var knockback_tween: Tween = create_tween()
	animated.modulate = Color.RED
	knockback_tween.tween_property(animated, "modulate", Color.WHITE, 0.25)
	is_hurtet = true
	animated.play("Hurt")
