extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	ManagerGame.items.append(Game.Item.Lampada)
	queue_free()
