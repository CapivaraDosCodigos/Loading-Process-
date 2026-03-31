extends Area2D
class_name AreaHitbox2d

func _on_body_entered(body: Node2D) -> void:
	if body is Player2D:
		body.velocity.y = body.JUMP_FORCE
		if owner is InimigoBase2D:
			owner.take_damage()
