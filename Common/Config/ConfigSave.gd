extends RefCounted
class_name ConfigSave

var section: String
var path: String
var config: ConfigFile

func _init(new_path: String, new_section: String) -> void:
	config = ConfigFile.new()
	path = new_path
	section = new_section

func save_file() -> Error:
	var error: Error = config.save(path)
	
	if error != Error.OK:
		push_warning("Falha ao salvar arquivo, error: ", error)
	
	return error

func load_file() -> Error:
	if not FileAccess.file_exists(path):
		return Error.ERR_FILE_NOT_FOUND
	
	var error: Error = config.load(path)
	
	if error != Error.OK:
		push_warning("Falha ao carregar arquivo, error: ", error)
	
	return error

func set_section(new_section: String) -> void:
	section = new_section

func set_value(key: String, value: Variant) -> void:
	config.set_value(section, key, value)

func get_value(key: String, default: Variant) -> Variant:
	return config.get_value(section, key, default)

func delete_file() -> Error:
	return DirAccess.remove_absolute(path)
