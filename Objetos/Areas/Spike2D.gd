extends Area2D
class_name Spike2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player2D:
		body.take_damage(Vector2(0, -body.jump_velocity))
	
	elif body is Enemy2D:
		body.take_damage()

func _on_area_entered(area: Area2D) -> void:
	if area is Coin2D:
		area._on_animated_animation_finished()
