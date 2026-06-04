## camera.gd :: main camera controller, bound by CameraAreas
class_name CameraCustom2D extends Camera2D

@export var player: CharacterBody2D

@export var LOOKAHEAD_STRENGTH: float = 100.0
@export var LOOKAHEAD_SPEED: float = 2.0
@export var SMOOTHING_SPEED: float = 5.0
@export var SMOOTHING_SNAP_THRESHOLD: float = 2.0
@export var ZOOM_SPEED: float = 3.0
@export var OFFSET_ABOVE_PLAYER: Vector2 = Vector2(0.0, -100)
@export var PEEK_DISTANCE: float = 160.0
@export var PEEK_TWEEN_DURATION: float = 0.4

var all_areas: Array[CameraArea2D] = []
var current_area: CameraArea2D
var previous_area: CameraArea2D
var transitioning: bool = false
var transition_tween: Tween

var velocity_smooth: Vector2 = Vector2.ZERO
var lookahead_target: Vector2 = Vector2.ZERO
var lookahead_current: Vector2 = Vector2.ZERO
var peek_tween: Tween = null

var base_offset: Vector2 = Vector2.ZERO
var peek_offset: Vector2 = Vector2.ZERO
var shake_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	ManagerGame.dead_player.connect(_reset_area)
	
	all_areas.assign(get_tree().get_nodes_in_group("camera_area"))
	
	_preload_objetos()
	
	base_offset = offset

func _physics_process(delta: float) -> void:
	offset = base_offset + peek_offset + shake_offset
	
	if not ManagerGame.player:
		return
	
	player = ManagerGame.player
	
	# Get the current CameraArea
	_find_current_area()

	# Determine where the camera wants to be
	var desired_position: Vector2 = _get_desired_position(delta)
	# Bind the desired position according to the area
	var bound_position: Vector2 = current_area.get_bound_position(desired_position) if current_area else desired_position

	# Smoothly move the camera, and adjust zoom
	_update_camera_position(bound_position, delta)
	_update_zoom(delta)

func _get_lookahead(delta: float) -> Vector2:
	var w: float = clamp(LOOKAHEAD_SPEED * delta, 0.0, 1.0)
	velocity_smooth = velocity_smooth.lerp(player.velocity, w)

	if velocity_smooth.length() > 10.0:
		lookahead_target = velocity_smooth.normalized() * LOOKAHEAD_STRENGTH
	lookahead_current = lookahead_current.lerp(lookahead_target, w)

	return lookahead_current

func _get_desired_position(delta: float) -> Vector2:
	#return player.global_position
	return player.global_position + OFFSET_ABOVE_PLAYER + _get_lookahead(delta)

func _update_camera_position(target_position: Vector2, delta: float) -> void:
	if transitioning:
		return

	if global_position.distance_to(target_position) < SMOOTHING_SNAP_THRESHOLD:
		global_position = target_position
	else:
		global_position = global_position.lerp(target_position, clamp(SMOOTHING_SPEED * delta, 0.0, 1.0))
		
	
	#var w: float = clamp(SMOOTHING_SPEED * delta, 0.0, 1.0)
	#global_position = global_position.lerp(target_position, w)

func _update_zoom(delta: float) -> void:
	if current_area:
		var target_zoom: float = current_area.zoom_level
		zoom = zoom.lerp(Vector2.ONE * target_zoom, ZOOM_SPEED * delta)

func _find_current_area() -> void:
	if ManagerGame.area_camera_inclusive:
		current_area = ManagerGame.area_camera_inclusive
		return
	
	var player_pos: Vector2 = player.global_position
	
	if current_area and current_area.contains_point(player_pos):
		return

	for area in all_areas:
		if area.contains_point(player_pos):
			if area != current_area:
				_enter_area(area)

func instant_snap() -> void:
	if not player:
		return
	
	velocity_smooth = Vector2.ZERO
	lookahead_target = Vector2.ZERO
	lookahead_current = Vector2.ZERO

	for area in all_areas:
		if area.contains_point(player.global_position):
			current_area = area
			global_position = area.get_bound_position(player.global_position + OFFSET_ABOVE_PLAYER)
			zoom = Vector2.ONE * area.zoom_level
			return

func _enter_area(next: CameraArea2D) -> void:
	previous_area = current_area
	current_area = next
	
	if not current_area.success:
		current_area.spawn()
	
	if not previous_area:
		return

	var desired: Vector2 = player.global_position + OFFSET_ABOVE_PLAYER + lookahead_current
	var new_bound_pos: Vector2 = current_area.get_bound_position(desired)
	var zoom_target: Vector2 = Vector2.ONE * current_area.zoom_level

	if transition_tween:
		transition_tween.kill()
	
	transitioning = true
	transition_tween = create_tween()
	transition_tween.set_trans(current_area.enter_trans).set_ease(current_area.enter_ease)
	transition_tween.tween_property(self, "global_position", new_bound_pos, current_area.enter_duration)
	transition_tween.parallel().tween_property(self, "zoom", zoom_target, current_area.enter_duration)
	transition_tween.finished.connect(func() -> void:
		transitioning = false
		if not previous_area:
			return
		
		if not previous_area.auto_restart and not previous_area.success:
			previous_area.despawn())

func _preload_objetos() -> void:
	var objetos: Array[Node] = get_tree().get_nodes_in_group("Spawner")
	
	for area in all_areas:
		area.precompute_aabb()
		
		for objeto in objetos:
			if area.contains_point(objeto.global_position) and objeto is Spawner2D:
				area.objetos.append(objeto)
		
		if area.isclusive:
			all_areas.erase(area)

func _reset_area() -> void:
	if current_area and not current_area.auto_restart:
		current_area.spawn()

# ========== SPECIAL EFFECTS ==========

func request_peek(dir: int) -> void:
	if dir == 0:
		cancel_peek()
		return
	var y: float = dir * PEEK_DISTANCE
	tween_peek(Vector2(0.0, y))

func cancel_peek() -> void:
	tween_peek(Vector2.ZERO)

func tween_peek(target: Vector2) -> void:
	if peek_tween:
		peek_tween.kill()
	
	peek_tween = create_tween()
	peek_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	peek_tween.tween_property(self, "peek_offset", target, PEEK_TWEEN_DURATION)

func shake(magnitude: float, duration: float) -> void:
	var elapsed: float = 0.0
	var shake_interval: float = 0.05

	while elapsed < duration:
		shake_offset = Vector2(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude)
		)
		await get_tree().create_timer(shake_interval).timeout
		elapsed += shake_interval

	shake_offset = Vector2.ZERO
