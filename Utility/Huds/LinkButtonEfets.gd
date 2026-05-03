extends LinkButton
class_name LinkButtonEffects

@export var focus_scale_multiplier: float = 1.25
@export var animation_duration: float = 0.15

var base_font_size: int
var base_outline_size: int

func _ready() -> void:
	base_font_size = get_theme_font_size("font_size")
	base_outline_size = get_theme_constant("outline_size")
	
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func _on_focus_entered() -> void:
	_animate_font(base_font_size * focus_scale_multiplier)

func _on_focus_exited() -> void:
	_animate_font(base_font_size)

func _animate_font(target_size: float) -> void:
	var current_tween: Tween = create_tween()
	current_tween.tween_method(_set_font_size, get_theme_font_size("font_size"), target_size, animation_duration)

func _set_font_size(value: float) -> void:
	add_theme_font_size_override("font_size", int(value))
