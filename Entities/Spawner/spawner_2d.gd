@tool
extends Marker2D
class_name Spawner2D

@export var packed_spawn: PackedSpawn:
	set(value):
		packed_spawn = value
		queue_redraw()
@export var extra_vars: Dictionary[StringName, Variant] = {}

var current_object: Node2D

func _get_configuration_warnings() -> PackedStringArray:
	var warning: PackedStringArray = []
	
	if not packed_spawn:
		warning.append("Este objeto não tem um PackedSpawn, considere adicionar um ao node")
	
	else:
		if not packed_spawn.preview_texture:
			warning.append("O PackedSpawn inserido não tem uma textura de válida, considere adicionar uma")
		
		if not packed_spawn.packed_scene:
			warning.append("O PackedSpawn inserido não tem um PackedScene de válido, considere adicionar um")
	
	return warning

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	
	if not packed_spawn:
		return
	
	if not packed_spawn.preview_texture:
		return
	
	var pos: Vector2 = (-packed_spawn.preview_texture.get_size() / 2)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1.0 if packed_spawn.flip_h else 1.0, 1.0))
	
	draw_texture(packed_spawn.preview_texture, pos + packed_spawn.offset)

func _set_extra_vars() -> void:
	for v: StringName in extra_vars.keys():
		current_object.set_deferred(v, extra_vars[v])

func spawn() -> void:
	if not packed_spawn.packed_scene or not packed_spawn:
		return
	
	if current_object:
		current_object.queue_free()
	
	current_object = packed_spawn.packed_scene.instantiate()
	current_object.global_position = global_position
	
	add_sibling.call_deferred(current_object)

func despawn() -> void:
	if current_object:
		current_object.queue_free()
