@tool
class_name CameraArea2D extends Polygon2D

#region
enum AreaType { STANDARD, FOCUS }

@export var necessary_coins: int = 1

@export_group("Area Settings")
@export var area_type: AreaType = AreaType.STANDARD:
	set(value):
		area_type = value
		notify_property_list_changed()
@export var zoom_level: float = 1.0
@export var has_spawned: bool = false
@export var exclusive: bool = false # Usado No Script da Câmera
@export var auto_restart: bool = false # Usado No Script da Câmera

@export var center_boundary: Polygon2D
@export var focus_point: Marker2D

@export_group("Transition Settings")
@export var enter_duration: float = 1.0
@export var enter_trans: Tween.TransitionType = Tween.TRANS_SINE
@export var enter_ease: Tween.EaseType = Tween.EASE_OUT

var cached_world_aabb: Rect2

var world_points: PackedVector2Array = []
var world_points_center_boundary: PackedVector2Array:
	get():
		if !world_points_center_boundary.is_empty():
			return world_points_center_boundary
		
		elif center_boundary:
			world_points_center_boundary = _get_world_polygon(center_boundary)
		return world_points_center_boundary
var objects: Array[Spawner2D] = []
var objects_in_cache: Array[Node2D] = []

func _init() -> void:
	add_to_group("camera_area")
	world_points = _get_world_polygon(self)
	_precompute_aabb()

func _to_string() -> String:
	return name

func _validate_property(property: Dictionary) -> void:
	if property.name == "center_boundary":
		if area_type != AreaType.STANDARD:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "focus_point":
		if area_type != AreaType.FOCUS:
			property.usage = PROPERTY_USAGE_NO_EDITOR

func _precompute_aabb() -> void:
	if polygon.size() == 0:
		return
	cached_world_aabb = Rect2(world_points[0], Vector2.ZERO)
	for point in world_points:
		cached_world_aabb = cached_world_aabb.expand(point)

func _get_world_polygon(poly: Polygon2D) -> PackedVector2Array:
	var pts: PackedVector2Array = poly.polygon
	var world: PackedVector2Array = []
	
	world.resize(pts.size())
	for i in pts.size():
		world[i] = poly.to_global(pts[i])
	return world

func _clamp_to_boundary(world_pos: Vector2) -> Vector2:
	if not center_boundary:
		return world_pos

	if Geometry2D.is_point_in_polygon(world_pos, world_points_center_boundary):
		return world_pos

	var closest: Vector2 = world_points_center_boundary[0]
	var min_dist_sq: float = world_pos.distance_squared_to(closest)

	for i in world_points_center_boundary.size():
		var a: Vector2 = world_points_center_boundary[i]
		var b: Vector2 = world_points_center_boundary[(i + 1) % world_points_center_boundary.size()]
		var candidate: Vector2 = Geometry2D.get_closest_point_to_segment(world_pos, a, b)
		var dist_sq: float = world_pos.distance_squared_to(candidate)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			closest = candidate

	return closest

func contains_point(point: Vector2) -> bool:
	if not cached_world_aabb.has_point(point):
		return false
		
	return Geometry2D.is_point_in_polygon(point, world_points)

func get_bound_position(desired: Vector2) -> Vector2:
	if area_type == AreaType.FOCUS and focus_point:
		return focus_point.global_position
	return _clamp_to_boundary(desired)

func spawn() -> void:
	if has_spawned:
		return

	for object in objects:
		object.spawn()

func despawn() -> void:
	for object in objects:
		object.despawn()
	
	for object in objects_in_cache:
		if object:
			object.queue_free()
	
	objects_in_cache.clear()

#region export tool

@export_group("Auto Boundary")
@export var boundary_scale: float = 0.8

@export_tool_button("Gerar Center Boundary")
var generate_boundary_action: Callable = _generate_center_boundary

const CENTER_BOUNDARY_NAME: String = "CenterBoundary"

func _generate_center_boundary() -> void:
	if polygon.size() < 3:
		push_warning("CameraArea2D: polígono precisa ter ao menos 3 pontos.")
		return

	var centroid: Vector2 = _polygon_centroid(polygon)

	var centered_points: PackedVector2Array = PackedVector2Array()
	centered_points.resize(polygon.size())
	for i in polygon.size():
		centered_points[i] = polygon[i] - centroid

	var boundary_node: Polygon2D = _get_or_create_boundary_child()
	boundary_node.position = centroid
	boundary_node.scale = Vector2.ONE * boundary_scale
	boundary_node.polygon = centered_points

	center_boundary = boundary_node
	notify_property_list_changed()

func _polygon_centroid(pts: PackedVector2Array) -> Vector2:
	var area_sum: float = 0.0
	var cx: float = 0.0
	var cy: float = 0.0
	var n: int = pts.size()

	for i in n:
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[(i + 1) % n]
		var cross: float = a.x * b.y - b.x * a.y
		area_sum += cross
		cx += (a.x + b.x) * cross
		cy += (a.y + b.y) * cross

	# Fallback pra polígono degenerado (pontos colineares, área ~0)
	if abs(area_sum) < 0.0001:
		var avg: Vector2 = Vector2.ZERO
		for p in pts:
			avg += p
		return avg / n

	var area: float = area_sum * 0.5
	cx /= (6.0 * area)
	cy /= (6.0 * area)
	return Vector2(cx, cy)

func _get_or_create_boundary_child() -> Polygon2D:
	var existing: Node = get_node_or_null(CENTER_BOUNDARY_NAME)
	if existing is Polygon2D:
		return existing

	var new_boundary: Polygon2D = Polygon2D.new()
	new_boundary.name = CENTER_BOUNDARY_NAME
	new_boundary.color = Color(0.0, 1.0, 0.0, 0.25)
	add_child(new_boundary)
	if Engine.is_editor_hint():
		new_boundary.owner = get_tree().edited_scene_root
	return new_boundary
#endregion
