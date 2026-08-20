extends Node
class_name Game

enum StateGame { InGame, TitleScreen }

signal dead_boss
signal player_out_screen
signal dead_player
signal shake_camera(magnitude: float, duration: float)

static var current: Game
static var scene: Node:
	set(value):
		scene = value
		if not scene:
			return
		elif scene is StageMap2D:
			current.dead_player.connect(scene._reload_game)

static var controls: CanvasLayer
static var game_hud: CanvasLayer
 
static var player: Player2D:
	set(value):
		player = value
		if player and current:
			current.player_out_screen.connect(player.die)
static var camera: CameraCustom2D:
	set(value):
		camera = value
		if camera and current:
			current.shake_camera.connect(camera.shake)
			current.dead_player.connect(camera.reset_current_area)
static var area_camera_inclusive: CameraArea2D

static var current_state: StateGame = StateGame.InGame: set = _set_current_state

static var is_paused_force: bool = false
static var paused_transition: bool = false

static var coins: int = 0
static var player_life: int = 3

# Informaçoes de save
static var score: int = 0
static var current_slot: int = 0
static var items: Array[GameResource.Item] = []

static var player_position: Vector2

@export var node_scene: Node

func _init() -> void:
	current = self
	dead_player.connect(_on_dead_player)

func _ready() -> void:
	controls = $Controls
	game_hud = $GameHUD
	
	if node_scene:
		scene = node_scene
	
	show_ui()

func _on_dead_player() -> void:
	player_position = Vector2.ZERO
	area_camera_inclusive = null

static func _set_current_state(value: StateGame) -> void:
	current_state = value
	#if current_state == StateGame.InGame:
		#show_ui()

static func show_ui() -> void:
	if controls:
		controls.show()
	
	if game_hud:
		game_hud.show()

static func hide_ui() -> void:
	controls.hide()
	game_hud.hide()

static func set_camera_position(new_position: Vector2) -> void:
	if camera:
		camera.global_position = new_position
