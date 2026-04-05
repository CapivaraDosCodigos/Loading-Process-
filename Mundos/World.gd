extends Node2D

@onready var player: Player2D = $Player
@onready var camera: Camera2D = $CameraLevel
@onready var player_scene: PackedScene = preload("uid://d15ddxvbvouva")
@onready var player_init_position: Vector2 = $Player.global_position

@export var audio: AudioStream

func _ready() -> void:
	Global.controls.show()
	Global.game_hud.show()
	
	Global.player = player
	Global.player.follow_camera(camera)
	Global.player.player_has_died.connect(reload_game)
	
	AudioManager.play_insurance(AudioManager.AudioType.MUSIC_1, audio, 100.0, false)

func reload_game() -> void:
	await get_tree().create_timer(1.0, false).timeout
	
	var new_player: Player2D = player_scene.instantiate()
	new_player.global_position = player_init_position
	
	add_child(new_player)
	
	Global.player = new_player
	Global.player.follow_camera(camera)
	Global.player.player_has_died.connect(reload_game)
	
	Global.coins = 0
	Global.score = 0
	Global.player_life = 3
	Global.respawn_player()
