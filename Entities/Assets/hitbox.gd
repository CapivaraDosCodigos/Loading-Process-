extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player2D:
		body.velocity.y = body.JUMP_FORCE
		owner.animated.play("Hurt")
