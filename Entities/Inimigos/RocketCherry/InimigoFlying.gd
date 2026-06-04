extends InimigoBase2D

const WAIT_DURATION: float = 0.25

@export var distance: float = 64.0
@export var move_horizonta: bool = false
@export var inimigo_center: float = 16.0
@export_file("*.tscn*") var inimigo_filho_path: String = ""
@export_group("Nodes")
@export var inimigo_marker: Marker2D

var start_position: Vector2
var follow: Vector2
var move_tween: Tween

func _internal_ready() -> void:
	start_position = global_position
	follow = start_position
	_move()

func _stop() -> void:
	set_physics_process(false)
	move_tween.pause()
	animated.pause()

func _play() -> void:
	set_physics_process(true)
	move_tween.play()
	animated.play()

func _on_animated_finished() -> void:
	if animated.animation == "Hurt":
		_spawn_new_inimigo()
		queue_free()

func _physics_process(_delta: float) -> void:
	position = position.lerp(follow, 0.5)

func _move() -> void:
	var move_direction: Vector2 = Vector2.RIGHT * distance if move_horizonta else Vector2.UP * distance
	var duration: float = move_direction.length() / (speed * inimigo_center)

	var target_pos: Vector2 = start_position + move_direction

	move_tween = create_tween().set_loops()
	move_tween.tween_property(self, "follow", target_pos, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_delay(WAIT_DURATION)
	move_tween.tween_property(self, "follow", start_position, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_delay(WAIT_DURATION)

func _spawn_new_inimigo() -> void:
	var inimigo_filho_load: PackedScene = load(inimigo_filho_path)
	var inimigo_filho: Node2D = inimigo_filho_load.instantiate()
	inimigo_filho.global_position = inimigo_marker.global_position
	inimigo_filho.scale = scale
	add_sibling(inimigo_filho)
	SpawnManager.add_objeto_in_cache_for_area(inimigo_filho)
