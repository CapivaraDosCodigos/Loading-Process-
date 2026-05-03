extends Node
class_name SceneManagerNode

## Gerenciador de troca de cenas com tela de loading e transições visuais, ideal para uso como AutoLoad global

## Cena da tela de loading utilizada durante a troca de cenas
const loading_screen: PackedScene = preload("uid://dp3hjnmnfokbw")

## Emitido quando o progresso de carregamento é atualizado
signal progress_changed(progress_array: Array)

## Emitido quando o carregamento da cena termina
signal load_finished

## Cena carregada em memória após o término do carregamento
var loaded_resource: PackedScene

## Caminho da cena que será carregada
var scene_path: String

## Array que armazena o progresso do carregamento (usado pela API threaded)
var progress: Array = []

## Define se o carregamento utilizará sub-threads internas
var use_sub_threads: bool = true

func _ready() -> void:
	set_process(false)

## Inicia o carregamento de uma nova cena com tela de transição
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
	#await load_finished

## Processa o carregamento assíncrono da cena e atualiza o progresso
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

## Inicia o pedido de carregamento assíncrono da cena
func _start_load() -> void:
	var state: Error = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)
