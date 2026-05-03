extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if not body is Player2D or ManagerGame.locate_point == self:
		return
	
	ManagerGame.locate_point_point = self
