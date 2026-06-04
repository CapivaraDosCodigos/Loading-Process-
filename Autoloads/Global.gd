extends Node

signal error_start

const start_scene_file: String = "uid://cxyrsj3the2k4"
const FILE_EXTENSION: String = ".tres"
const PATH_FORMAT: String = "_%d" + FILE_EXTENSION

func start_game(slot: int) -> void:
	var save: Save = Save.load_file(Game.SAVE_PATH % slot)
	
	if save == null:
		error_start.emit()
		return
	
	ManagerGame.items = save.items
	ManagerGame.score = save.score
	ManagerGame.current_slot = slot
	
	SceneManager.load_scene(save.current_stage, true, "transition_4")

func get_camera() -> CameraCustom2D:
	return get_viewport().get_camera_2d() as CameraCustom2D

func set_time_scale(value: float) -> void:
	Engine.time_scale = value
