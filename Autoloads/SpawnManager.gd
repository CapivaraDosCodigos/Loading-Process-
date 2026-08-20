extends RefCounted
class_name SpawnManager

static var objetos_in_cache: Array[Node2D] = []

static func add_objeto_in_cache_for_area(objeto: Node2D) -> void:
	if not objeto:
		return
	
	var camera: CameraCustom2D = Game.camera
	if not camera:
		return
	
	for area: CameraArea2D in camera.all_areas:
		if area.contains_point(objeto.global_position):
			area.objects_in_cache.append(objeto)
			break

static func add_objeto_in_cache(objeto: Node2D) -> void:
	if not objeto:
		return
	
	objetos_in_cache.append(objeto)

static func despawn_objeto_in_cache() -> void:
	for objeto in objetos_in_cache:
		if objeto:
			objeto.queue_free()
	objetos_in_cache.clear()
