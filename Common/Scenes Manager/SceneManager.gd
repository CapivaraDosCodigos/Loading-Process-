extends Node

const loading_screen: PackedScene = preload("uid://dp3hjnmnfokbw")

signal progress_changed(progress_array: Array)
signal load_finished

var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true

func _ready() -> void:
	set_process(false)

func load_scene(_scene_path: String, _use_sub_threads: bool = true, transition: String = "transition_1") -> void:
	if not FileAccess.file_exists(_scene_path):
		push_warning("Nao existe arquivo na path: ", _scene_path)
		return
	
	scene_path = _scene_path
	use_sub_threads = _use_sub_threads
	
	var new_load_screen: LoadScreen = loading_screen.instantiate()
	new_load_screen.type_transition = transition
	add_child(new_load_screen)
	progress_changed.connect(new_load_screen._on_progress_changed)
	load_finished.connect(new_load_screen._on_load_finished)
	
	await new_load_screen.loading_screen_ready
	_start_load()

func _process(_delta: float) -> void:
	var load_status := ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			push_warning("Falha ao carregar a recurso da cena")
			set_process(false)
			
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			if loaded_resource is PackedScene:
				get_tree().change_scene_to_packed(loaded_resource)
				
			else:
				push_warning("Resourse nao eh uma cena: ", loaded_resource)
			
			load_finished.emit()
			set_process(false)

func _start_load() -> void:
	var state := ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)
