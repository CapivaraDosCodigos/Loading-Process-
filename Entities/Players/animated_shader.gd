extends AnimatedSprite2D

func _ready() -> void:
	var tween: Tween = create_tween()
	tween.tween_method(_set_shader, material.get("shader_parameter/blink_color"), Color.TRANSPARENT, 0.2)
	tween.finished.connect(_on_finished)

func _set_shader(color: Color) -> void:
	material.set("shader_parameter/blink_color", color)

func _on_finished() -> void:
	queue_free()
