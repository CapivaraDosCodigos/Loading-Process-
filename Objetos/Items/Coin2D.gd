extends Area2D
class_name Coin2D

@onready var animated: AnimatedSprite2D = $Animated

func _on_body_entered(_body: Node2D) -> void:
	add_moeda.call_deferred()

func add_moeda() -> void:
	print("+ moeda")
	var parent: Node = get_parent()
	if parent is RigidBody2D:
		parent.freeze = true
	
	animated.play("End")

func _on_animated_animation_finished() -> void:
	if get_parent() is RigidBody2D:
		get_parent().queue_free()
	else:
		queue_free()
