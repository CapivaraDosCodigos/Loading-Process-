extends Area2D
class_name AreaSecret2D

@export var shadow: ColorRect

func _get_configuration_warnings() -> PackedStringArray:
	if shadow:
		return []
	return ["Por favor, Adicione um ColorRect"]

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(_body: Node2D) -> void:
	if shadow:
		shadow.modulate = Color(1.0, 1.0, 1.0, 0.5)

func _on_body_exited(_body: Node2D) -> void:
	if shadow:
		shadow.modulate = Color.WHITE
