extends Area2D
class_name AreaHitbox2d

func _on_body_entered(body: Node2D) -> void:
	if body is Player2D:
		if owner is InimigoBase2D and owner:
			owner.take_damage(body)
