extends Area2D

var is_active: bool = false
@onready var animated: AnimatedSprite2D = $Animated

func _on_body_entered(body: Node2D) -> void:
	if not body is Player2D or is_active:
		return
	activate_checkpoint()

func activate_checkpoint() -> void:
	EventBus.check_point = self
	animated.play("raising")
	is_active = true

func _on_animated_animation_finished() -> void:
	if animated.animation == "raising":
		animated.play("checked")
		
		
