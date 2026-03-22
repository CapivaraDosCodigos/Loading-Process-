extends Node2D

@onready var player: Player2D = $Player
@onready var camera: Camera2D = $'Camera'

func _ready() -> void:
	player.follow_camera(camera)
