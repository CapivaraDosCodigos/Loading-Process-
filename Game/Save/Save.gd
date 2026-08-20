extends Resource
class_name Save

@export var current_stage: String = "uid://blc6rhvbms5rr"
@export var invocations: PackedStringArray = []
@export var items: Array[GameResource.Item] = []
@export var score: int = 0

static func save_file(path: String, resource: Save) -> Error:
	var err: Error = ResourceSaver.save(resource, path)
	
	if err != OK:
		push_warning("Falha ao salvar arquivo, error: ", err)
	
	return err

static func load_file(path: String) -> Save:
	if not FileAccess.file_exists(path):
		push_warning("Arquivo não existe em: " + path)
		return Save.new()
	
	var loaded_resource: Save = ResourceLoader.load(path)
	
	if not loaded_resource:
		push_warning("Falha ao carregar arquivo de save: " + path)
		return null
	
	return loaded_resource.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)

static func delete_file(path: String) -> Error:
	return DirAccess.remove_absolute(path)
