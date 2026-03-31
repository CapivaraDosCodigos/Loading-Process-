extends Area2D
class_name Spike2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player2D:
		body.take_damage(Vector2(0, -250))
	elif body is InimigoGround2D:
		body.take_damage()
