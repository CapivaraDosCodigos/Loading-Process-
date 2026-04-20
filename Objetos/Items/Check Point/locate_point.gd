extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if not body is Player2D or Global.locate_point == self:
		return
	
	Global.locate_point_point = self
