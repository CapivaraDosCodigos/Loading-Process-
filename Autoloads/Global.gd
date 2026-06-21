extends Node

signal progress_scene_changed(progress_array: Array)
signal load_scene_finished
signal error_start

const LOADING_SCREEN: PackedScene = preload("uid://dp3hjnmnfokbw")
const BACKGROUND_GAME: PackedScene = preload("uid://c8cue0dknqoqf")
const start_scene_file: String = "uid://cxyrsj3the2k4"
const FILE_EXTENSION: String = ".tres"
const PATH_FORMAT: String = "_%d" + FILE_EXTENSION

var current_scene: Node
var loaded_resource: PackedScene
var progress: Array = []
var scene_path: String
var use_sub_threads: bool = true

func start_game(slot: int) -> void:
	var save: Save = Save.load_file(Game.SAVE_PATH % slot)
	
	if save == null:
		error_start.emit()
		return
		
	ManagerGame.inGame = true
	ManagerGame.items = save.items
	ManagerGame.score = save.score
	ManagerGame.current_slot = slot
	
	load_scene(save.current_stage, true, "transition_4")

func get_camera() -> CameraCustom2D:
	return get_viewport().get_camera_2d() as CameraCustom2D

func set_time_scale(value: float) -> void:
	Engine.time_scale = value

func load_scene(_scene_path: String, _use_sub_threads: bool = true, transition: String = "transition_1") -> void:
	if not FileAccess.file_exists(_scene_path):
		push_warning("Nao existe arquivo na path: ", _scene_path)
		return
	
	scene_path = _scene_path
	use_sub_threads = _use_sub_threads
	
	var new_load_screen: LoadScreen = LOADING_SCREEN.instantiate()
	new_load_screen.type_transition = transition
	ManagerGame.add_child(new_load_screen)
	progress_scene_changed.connect(new_load_screen._on_progress_changed)
	load_scene_finished.connect(new_load_screen._on_load_finished)
	
	await new_load_screen.loading_screen_ready
	_start_load_scene()

func _ready() -> void:
	set_process(false)
	await get_tree().process_frame
	
	var back: ColorRect = BACKGROUND_GAME.instantiate()
	add_sibling(back)
	current_scene = get_tree().current_scene
	get_tree().current_scene.reparent(ManagerGame)

func _scene_changed(packed: PackedScene) -> void:
	var packed_instantiate: Node = packed.instantiate()
	ManagerGame.add_child(packed_instantiate)
	
	if current_scene:
		current_scene.queue_free()
	
	current_scene = packed_instantiate

func _process(_delta: float) -> void:
	var load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_scene_changed.emit(progress[0])
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			push_warning("Falha ao carregar a recurso da cena")
			set_process(false)
			
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			if loaded_resource is PackedScene:
				_scene_changed(loaded_resource)
				
			else:
				push_warning("Resourse nao eh uma cena: ", loaded_resource)
			
			load_scene_finished.emit()
			set_process(false)

func _start_load_scene() -> void:
	var state: Error = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)
