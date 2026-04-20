extends Resource
class_name ResourceSaverLoader

## Sistema estático para salvar, carregar e gerenciar recursos em disco com suporte opcional a thread

## Thread única usada para operações assíncronas de salvamento
static var _thread: Thread = null

## Define se o sistema utilizará thread para salvar recursos
static var _use_thread: bool = false

## Indica se o sistema está ocupado com uma operação de salvamento
static var _is_busy: bool = false

## Ativa ou desativa o uso de thread para salvar recursos
static func set_use_thread(value: bool) -> void:
	_use_thread = value
	
	if _use_thread and _thread == null:
		_thread = Thread.new()

## Retorna se o sistema está ocupado salvando um recurso
static func is_busy() -> bool:
	return _is_busy

## Carrega um recurso do caminho especificado, validando o tipo e podendo retornar null ou um novo recurso
static func load_resource(path: String, type_resource: GDScript, return_null: bool = false) -> Resource:
	if not FileAccess.file_exists(path):
		push_warning("Arquivo não existe em: " + path)
		return null if return_null else type_resource.new()
	
	var loaded_resource: Resource = ResourceLoader.load(path)
	
	if not loaded_resource:
		push_warning("Falha ao carregar arquivo de save: " + path)
		return null if return_null else type_resource.new()
	
	if loaded_resource.get_script() != type_resource:
		push_warning("Tipo referenciado não pertence ao arquivo em: " + path)
		return null if return_null else type_resource.new()
	
	return loaded_resource.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)

## Salva um recurso no caminho especificado, podendo usar thread ou execução direta
static func save_resource(path: String, resource: Resource) -> Error:
	if _use_thread:
		return _save_threaded(path, resource)
	
	return _save_internal(path, resource)

## Remove um recurso salvo do disco pelo caminho especificado
static func delete_resource(path: String) -> Error:
	if not FileAccess.file_exists(path):
		return ERR_DOES_NOT_EXIST
	
	return DirAccess.remove_absolute(path)

## Verifica se um recurso existe no caminho especificado
static func resource_exists(path: String) -> bool:
	return FileAccess.file_exists(path)

## Executa o salvamento em uma thread separada, evitando travar o jogo
static func _save_threaded(path: String, resource: Resource) -> Error:
	if _is_busy:
		return ERR_BUSY
	
	_is_busy = true
	
	var data: Dictionary = {
		"path": path,
		"resource": resource.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	}
	
	var err: Error = _thread.start(_thread_save.bind(data))
	
	if err != OK:
		_is_busy = false
	
	return err

## Função executada dentro da thread para salvar o recurso
static func _thread_save(data: Dictionary) -> void:
	_save_internal(data.path, data.resource)
	_is_busy = false

## Função interna responsável por salvar o recurso diretamente no disco
static func _save_internal(path: String, resource: Resource) -> Error:
	var err: Error = ResourceSaver.save(resource, path)
	
	if err != OK:
		push_warning("Falha ao salvar arquivo em: " + path)
	
	return err
