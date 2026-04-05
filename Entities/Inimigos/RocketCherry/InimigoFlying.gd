extends InimigoBase2D

const WAIT_DURATION: float = 0.25

@export var distance: float = 192.0
@export var move_horizonta: bool = false
@export var inimigo_center: float = 16.0
@export_file("*.tscn*") var inimigo_filho_path: String = ""
@export_group("Nodes")
@export var inimigo_marker: Marker2D

var follow: Vector2
var start_pos: Vector2
var move_tween: Tween

func _internal_ready() -> void:
	start_pos = position
	follow = start_pos
	_move()

func _stop() -> void:
	set_physics_process(false)
	move_tween.pause()
	animated.pause()

func _play() -> void:
	set_physics_process(true)
	move_tween.play()
	animated.play()

func _on_animated_animation_finished() -> void:
	if animated.animation == "Hurt":
		Global.score += score
		_spawn_new_inimigo()
		queue_free()

func _physics_process(_delta: float) -> void:
	position = position.lerp(follow, 0.5)

func _move() -> void:
	var move_direction: Vector2 = Vector2.RIGHT * distance if move_horizonta else Vector2.UP * distance
	var duration: float = move_direction.length() / (speed * inimigo_center)

	var target_pos: Vector2 = start_pos + move_direction

	move_tween = create_tween().set_loops()
	move_tween.tween_property(self, "follow", target_pos, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_delay(WAIT_DURATION)
	move_tween.tween_property(self, "follow", start_pos, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_delay(WAIT_DURATION)

func _spawn_new_inimigo() -> void:
	var inimigo_filho_load: PackedScene = load(inimigo_filho_path)
	var inimigo_filho: Node2D = inimigo_filho_load.instantiate()
	inimigo_filho.global_position = inimigo_marker.global_position
	inimigo_filho.scale = scale
	add_sibling(inimigo_filho)

func take_damage(player: Player2D = null) -> void:
	if player:
		player.velocity.y = -player.jump_velocity
	
	velocity = Vector2.ZERO
	var knockback_tween: Tween = create_tween()
	animated.modulate = Color.RED
	knockback_tween.tween_property(animated, "modulate", Color.WHITE, 0.25)
	animated.play("Hurt")
