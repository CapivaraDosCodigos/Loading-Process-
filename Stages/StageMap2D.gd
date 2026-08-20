extends Node2D
class_name StageMap2D

static var player_scene: PackedScene = preload("uid://d15ddxvbvouva")

@export var player: Player2D
@export var player_father: Node2D
@export var audio: AudioStream

var player_init_position: Vector2

func _ready() -> void:
	if player:
		Game.player = player
		player_init_position = player.global_position
		Game.camera.instant_snap()
	
	if audio:
		AudioManager.play_insurance(AudioGame.MUSIC_1, audio, 100.0)

func _reload_game() -> void:
	SpawnManager.despawn_objeto_in_cache()
	
	var canvas: CanvasTransition = CanvasTransition.create_canvas_transition(
		"uid://uxt5n5ltkiik", {"uv_y": 0.0})
	add_sibling(canvas)
	
	await canvas.loading_screen_ready
	
	Game.score = 0
	Game.player_life = 3
	
	var new_player: Player2D = player_scene.instantiate()
	new_player.global_position = player_init_position
	
	if player_father:
		player_father.add_child(new_player)
	else:
		add_child(new_player)
	
	Game.player = new_player
	Game.camera.instant_snap()
	canvas.set_shader_parameters({"inverted": true})
	await get_tree().create_timer(1.0, false).timeout
	canvas._on_load_finished()
