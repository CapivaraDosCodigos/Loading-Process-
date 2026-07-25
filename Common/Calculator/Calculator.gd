extends RefCounted
class_name MathGame

static func get_screen_uv_from_node(node: Node2D) -> Vector2:
	if not node:
		return Vector2.ZERO
	
	var viewport: Viewport = node.get_viewport()
	var camera2d: Camera2D = viewport.get_camera_2d()
	
	if not camera2d:
		return Vector2.ZERO
	
	var global_pos: Vector2 = node.global_position
	
	var screen_pos: Vector2 = node.get_viewport().get_canvas_transform() * global_pos
	
	var size: Vector2 = viewport.get_visible_rect().size

	var uv: Vector2 = screen_pos / size
	
	return uv

static func get_screen_position_from_node(node: Node2D) -> Vector2:
	if not node:
		return Vector2.ZERO
	
	var viewport: Viewport = node.get_viewport()
	var camera2d: Camera2D = viewport.get_camera_2d()
	
	if not camera2d:
		return Vector2.ZERO
	
	var global_pos: Vector2 = node.global_position
	
	var screen_pos: Vector2 = node.get_viewport().get_canvas_transform() * global_pos
	
	return screen_pos

static func is_vertical_hit(body_pos: Vector2, target_pos: Vector2, tolerance: float = 8.0) -> bool:
	return abs(target_pos.y - body_pos.y) > tolerance

static func calculate_knockback(body_pos: Vector2, target_pos: Vector2, knockback_height: float, knockback_power: float) -> Vector2:
	var y_force: float = -knockback_height# if is_vertical_hit(body_pos, target_pos) else 0.0
	var x_force: float = Vector2((body_pos.x - target_pos.x), 0.0).normalized().x
	return Vector2(x_force * knockback_power, y_force)

static func desnormalized(vector: Vector2) -> Vector2:
	if vector.x != 0.0:
		vector.x = abs(vector.x) / vector.x
		
	if vector.y != 0.0:
		vector.y = abs(vector.y) / vector.y
	
	return vector
