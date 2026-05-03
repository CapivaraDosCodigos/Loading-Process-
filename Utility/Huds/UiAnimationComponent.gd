extends Node
class_name UiAnimationComponent

@export var animate_from_center: bool = true
@export var animate_scale: Vector2 = Vector2.ONE * 1.25
@export var animation_duration: float = 0.2
@export var transition_type: Tween.TransitionType 

var target: Control
var default_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	if get_parent() is Control:
		target = get_parent()
		_setup.call_deferred()

func _setup() -> void:
	target.mouse_entered.connect(_on_mouse_entered)
	target.mouse_exited.connect(_on_mouse_exited)
	
	if animate_from_center:
		target.pivot_offset = target.size / 2.0
	default_scale = target.scale

func _on_mouse_entered() -> void:
	_init_tween("scale", animate_scale, animation_duration)

func _on_mouse_exited() -> void:
	_init_tween("scale", default_scale, animation_duration)

func _init_tween(property: NodePath, value: Variant, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(target, property, value, duration).set_trans(transition_type)
