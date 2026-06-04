extends Node2D
class_name StageMap2D

static var player_scene: PackedScene = preload("uid://d15ddxvbvouva")

@onready var camera: CameraCustom2D = %CameraLevel
@export var player: Player2D
@export var node_pai: Node2D
var player_init_position: Vector2

@export var audio: AudioStream

func _ready() -> void:
	ManagerGame.show_ui()
	ManagerGame.dead_player.connect(_reload_game)
	
	if player:
		ManagerGame.player = player
		player_init_position = player.global_position
	
	ManagerGame.camera = camera
	
	if audio:
		AudioManager.play_insurance(AudioGame.MUSIC_1, audio, 100.0)

func _reload_game() -> void:
	await get_tree().create_timer(1.0, false).timeout
	
	ManagerGame.score = 0
	ManagerGame.player_life = 3
	
	var new_player: Player2D = player_scene.instantiate()
	new_player.global_position = player_init_position
	
	if node_pai:
		node_pai.add_child(new_player)
	else:
		add_child(new_player)
	
	ManagerGame.player = new_player
	
	ManagerGame.respawn_player()
