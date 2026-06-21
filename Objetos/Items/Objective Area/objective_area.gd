extends Area2D

@export_file("*.tscn*") var scene_path: String = ""

func _on_body_entered(_body: Node2D) -> void:
	if scene_path != "":
		Global.load_scene(scene_path, true, "transition_2")
