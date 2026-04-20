extends Node2D
class_name StageMap2D

static var player_scene: PackedScene = preload("uid://d15ddxvbvouva")

@onready var camera: CameraEffect2D = $CameraLevel
@onready var player: Player2D = $Player
@onready var player_init_position: Vector2 = $Player.global_position

@export var audio: AudioStream

func _ready() -> void:
	Global.controls.show()
	Global.game_hud.show()
	
	Global.dead_player.connect(_reload_game)
	
	Global.player = player
	Global.camera = camera
	Global.player.follow_camera(camera)
	
	AudioManager.play_insurance(0, audio, 80.0, true)

func _reload_game() -> void:
	await get_tree().create_timer(1.0, false).timeout
	
	Global.coins = 0
	Global.score = 0
	Global.player_life = 9
	
	var new_player: Player2D = player_scene.instantiate()
	new_player.global_position = player_init_position
	
	add_child(new_player)
	
	Global.player = new_player
	Global.player.follow_camera(camera)
	
	Global.respawn_player()
