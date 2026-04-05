extends Area2D

func _on_head_area_body_entered(body: Node2D) -> void:
	if body is BreakBox2D and owner.velocity.y < 0 and not owner.is_on_floor():
		body.break_sprites()
