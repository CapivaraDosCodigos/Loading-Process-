extends Area2D
class_name AreaHitbox2D

var collision: CollisionShape2D

func _ready() -> void:
	for child in get_children():
		if child is CollisionShape2D:
			collision = child
			break

func _on_body_entered(body: Node2D) -> void:
	if not owner:
		return
	
	elif body is Player2D:
		if not body.is_attack:
			return
		
		elif owner is InimigoBase2D:
			owner.take_damage(body)
	
	elif body is InimigoBase2D:
		body.take_damage(null)

func set_disabled(value: bool) -> void:
	if collision:
		collision.set_deferred("disabled", value)
