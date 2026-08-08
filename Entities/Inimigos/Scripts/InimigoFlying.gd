@tool
extends Enemy2D

@export var move_horizontal: bool = false
@export var wait_duration: float = 0.25
@export var distance: float = 64.0

@export_file("*.tscn*") var inimigo_filho_path: String = ""
@export var inimigo_marker: Marker2D

var start_position: Vector2
var last_position: Vector2 = Vector2.ZERO
var follow: Vector2

var move_tween: Tween

func _init() -> void:
	if Engine.is_editor_hint():
		return
		
	super._init()
	start_position = global_position
	follow = start_position
	_move()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if is_hurtet:
		_gravity(delta)
	else:
		position = position.lerp(follow, 0.5)
		_apply_flip()

func apply_stun(duration: float = 0.30) -> void:
	is_stun = true
	move_tween.pause()
	
	await get_tree().create_timer(duration).timeout
	
	move_tween.play()
	is_stun = false

func _die() -> void:
	_spawn_new_inimigo()
	queue_free()

func _apply_flip() -> void:
	var velocity_p: Vector2 = last_position - global_position
	last_position = global_position
	
	direction.x = -Vector2(velocity_p.x, 0.0).normalized().x
	
	if direction.x == 0.0:
		return
	
	if animated:
		animated.scale.x = direction.x
		
	elif sprite:
		sprite.scale.x = direction.x

func _move() -> void:
	var move_direction: Vector2 = Vector2.RIGHT * distance if move_horizontal else Vector2.UP * distance
	var duration: float = move_direction.length() / (speed * size.x / 2)

	var target_pos: Vector2 = start_position + move_direction

	move_tween = create_tween().set_loops()
	move_tween.tween_property(self, "follow", target_pos, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_delay(wait_duration)
	move_tween.tween_property(self, "follow", start_position, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_delay(wait_duration)

func _spawn_new_inimigo() -> void:
	if inimigo_filho_path == "":
		return
	
	var inimigo_filho_load: PackedScene = load(inimigo_filho_path)
	var inimigo_filho: Node2D = inimigo_filho_load.instantiate()
	inimigo_filho.global_position = inimigo_marker.global_position
	inimigo_filho.scale = scale
	add_sibling(inimigo_filho)
	SpawnManager.add_objeto_in_cache_for_area(inimigo_filho)
