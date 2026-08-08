extends Window

var inGame: bool = true

@onready var controls: CanvasLayer = $Controls
@onready var game_hud: CanvasLayer = $GameHUD

@warning_ignore("unused_signal")
signal dead_boss

signal dead_player
signal shake_camera(magnitude: float, duration: float)

var is_paused_force: bool = false
var paused_transition: bool = false

var coins: int = 0
var player_life: int = 3

# Informaçoes de save
var score: int = 0
var current_slot: int = 0
var items: Array[Game.Item] = [Game.Item.ScalingEquipment, Game.Item.Dash]

var player_position: Vector2

var player: Player2D
var camera: CameraCustom2D
var area_camera_inclusive: CameraArea2D

func _ready() -> void:
	dead_player.connect(_on_dead_player)

func _on_dead_player() -> void:
	shake_camera.emit(2.0, 1.0)
	player_position = Vector2.ZERO
	area_camera_inclusive = null

func show_ui() -> void:
	controls.show()
	game_hud.show()

func hide_ui() -> void:
	controls.hide()
	game_hud.hide()

func set_camera_position(new_position: Vector2) -> void:
	if camera:
		camera.global_position = new_position

func set_transparent(value: bool) -> void:
	transparent = value
