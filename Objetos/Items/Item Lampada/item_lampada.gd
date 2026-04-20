extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	Global.items.append(Global.Item.Lampada)
	queue_free()
