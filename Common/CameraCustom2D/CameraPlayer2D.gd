extends CameraCustom2D
class_name CameraPlayer2D

@export var lookahead_strength: float = 100.0
@export var lookahead_speed: float = 2.0
@export var lookahead_min_speed: float = 10.0
@export var smoothing_snap_threshold: float = 2.0

var velocity_smooth: Vector2 = Vector2.ZERO
var lookahead_target: Vector2 = Vector2.ZERO
var lookahead_current: Vector2 = Vector2.ZERO

func _get_lookahead(delta: float) -> Vector2:
	var w: float = clamp(lookahead_speed * delta, 0.0, 1.0)
	velocity_smooth = velocity_smooth.lerp(player.velocity, w)

	if velocity_smooth.length() > lookahead_min_speed:
		lookahead_target = velocity_smooth.normalized() * lookahead_strength
	lookahead_current = lookahead_current.lerp(lookahead_target, w)

	return lookahead_current

func _get_desired_position(delta: float) -> Vector2:
	return player.global_position + offset_above_player + _get_lookahead(delta)

func _update_camera_position(target_position: Vector2, delta: float) -> void:
	if transitioning:
		return

	if global_position.distance_to(target_position) < smoothing_snap_threshold:
		global_position = target_position
	else:
		global_position = global_position.lerp(target_position, clamp(smoothing_speed * delta, 0.0, 1.0))

func _enter_area(next: CameraArea2D) -> void:
	if transitioning and previous_area:
		_try_despawn_area(previous_area)

	previous_area = current_area
	current_area = next
	current_area.spawn()

	if not previous_area:
		return

	var desired: Vector2 = player.global_position + offset_above_player + lookahead_current
	var new_bound_pos: Vector2 = current_area.get_bound_position(desired)
	var zoom_target: Vector2 = Vector2.ONE * current_area.zoom_level

	if transition_tween:
		transition_tween.kill()

	transitioning = true
	player.process_mode = Node.PROCESS_MODE_DISABLED
	transition_tween = create_tween()
	transition_tween.set_trans(current_area.enter_trans).set_ease(current_area.enter_ease)
	transition_tween.tween_property(self, "global_position", new_bound_pos, current_area.enter_duration)
	transition_tween.parallel().tween_property(self, "zoom", zoom_target, current_area.enter_duration)
	transition_tween.finished.connect(_on_transition_finished.bind(previous_area))

func instant_snap() -> void:
	if not player:
		return
	
	velocity_smooth = Vector2.ZERO
	lookahead_target = Vector2.ZERO
	lookahead_current = Vector2.ZERO

	for area in all_areas:
		if area.contains_point(player.global_position):
			current_area = area
			global_position = area.get_bound_position(player.global_position + offset_above_player)
			zoom = Vector2.ONE * area.zoom_level
			break
