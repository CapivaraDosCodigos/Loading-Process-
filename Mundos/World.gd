extends Node2D

@onready var player: Player2D = $Player
@onready var camera: Camera2D = $CameraLevel
@onready var player_scene: PackedScene = preload("uid://d15ddxvbvouva")
@onready var start_player_position: Vector2

func _ready() -> void:
	EventBus.player = player
	EventBus.player.follow_camera(camera)
	EventBus.player.player_has_died.connect(reload_game)
	start_player_position = player.global_position

func reload_game() -> void:
	await get_tree().create_timer(1.0, false).timeout
	
	var new_player: Player2D = player_scene.instantiate()
	new_player.global_position = start_player_position
	
	add_child(new_player)
	
	EventBus.player = new_player
	EventBus.player.follow_camera(camera)
	EventBus.player.player_has_died.connect(reload_game)
	
	EventBus.coins = 0
	EventBus.score = 0
	EventBus.player_life = 3
	EventBus.respawn_player()
