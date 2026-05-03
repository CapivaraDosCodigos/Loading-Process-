extends Node

signal error_start

const start_scene_file: String = "uid://cxyrsj3the2k4"
const FILE_EXTENSION: String = ".tres"
const PATH_FORMAT: String = "_%d" + FILE_EXTENSION

func start_game(slot: int) -> void:
	var save: Save = Save.load_file(Game.SAVE_PATH % slot)
	ManagerGame.current_slot = slot
	
	if save == null:
		error_start.emit()
		print("carai")
		return
	
	ManagerGame.items = save.items
	SceneManager.load_scene(start_scene_file, true, "transition_4")
	#Save.save_file(Game.SAVE_PATH % slot, save)

func set_time_scale(value: float) -> void:
	Engine.time_scale = value
