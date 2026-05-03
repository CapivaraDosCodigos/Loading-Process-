extends Node2D
class_name StageMap2D

static var player_scene: PackedScene = preload("uid://d15ddxvbvouva")

@onready var camera: CameraEffect2D = %CameraLevel
@onready var player: Player2D = %Player
@onready var player_init_position: Vector2 = %Player.global_position

@export var audio: AudioStream

func _ready() -> void:
	ManagerGame.show_ui()
	ManagerGame.dead_player.connect(_reload_game)
	
	ManagerGame.player = player
	ManagerGame.camera = camera
	player.follow_camera(camera)
	
	if audio:
		AudioManager.play_insurance(0, audio, 80.0, true)

func _reload_game() -> void:
	await get_tree().create_timer(1.0, false).timeout
	
	ManagerGame.coins = 0
	ManagerGame.score = 0
	ManagerGame.player_life = 9
	
	var new_player: Player2D = player_scene.instantiate()
	new_player.global_position = player_init_position
	
	add_child(new_player)
	
	ManagerGame.player = new_player
	ManagerGame.player.follow_camera(camera)
	
	ManagerGame.respawn_player()
