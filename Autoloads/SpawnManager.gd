extends Node

var objetos_in_cache: Array[Node2D] = []

func _ready() -> void:
	ManagerGame.dead_player.connect(despawn_objeto_in_cache)

func add_objeto_in_cache_for_area(objeto: Node2D) -> void:
	if not objeto:
		return
	
	var camera: CameraCustom2D = ManagerGame.camera
	if not camera:
		return
	
	for area: CameraArea2D in camera.all_areas:
		if area.contains_point(objeto.global_position):
			area.objetos_in_cache.append(objeto)
			break

func add_objeto_in_cache(objeto: Node2D) -> void:
	if not objeto:
		return
	
	objetos_in_cache.append(objeto)

func despawn_objeto_in_cache() -> void:
	for objeto in objetos_in_cache:
		if objeto:
			queue_free()
	objetos_in_cache.clear()
