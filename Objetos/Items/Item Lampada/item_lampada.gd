extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	if not Game.Item.Lampada in ManagerGame.items:
		ManagerGame.items.append(Game.Item.Lampada)
	queue_free()
