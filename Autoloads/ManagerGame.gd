extends Window

var inGame: bool = true

@onready var controls: CanvasLayer = $Controls
@onready var game_hud: CanvasLayer = $GameHUD

@onready var efeitoTimeStop: ShaderMaterial = %Invertido.material
@onready var colorInvertido: ColorRect = %Invertido
@onready var colorBase: ColorRect = %Base
@onready var animator: AnimationPlayer = $GameHUD/Animator

signal time_stop
signal time_play

@warning_ignore("unused_signal")
signal dead_player
@warning_ignore("unused_signal")
signal dead_boss

var is_paused_force: bool = false
var is_paused: bool = false
var paused_transition: bool = false

var coins: int = 0
var player_life: int = 3

# Informaçoes de save
var score: int = 0
var current_slot: int = 0
var items: Array[Game.Item] = [Game.Item.ScalingEquipment, Game.Item.Dash]

var player: Player2D
var check_point: Node2D
var locate_point: Node2D

var camera: CameraCustom2D
var area_camera_inclusive: CameraArea2D

func show_ui() -> void:
	controls.show()
	game_hud.show()

func hide_ui() -> void:
	controls.hide()
	game_hud.hide()

func set_transparent(value: bool) -> void:
	transparent = value

func respawn_player() -> void:
	if check_point:
		player.global_position = check_point.global_position

func time_stop_event() -> void:
	is_paused = true
	time_stop.emit()
	
	await _apply_time_effect(true)

	await get_tree().create_timer(3.5, false).timeout

	await _apply_time_effect(false)

	time_play.emit()
	is_paused = false

func _apply_time_effect(start: bool) -> void:
	var uv: Vector2 = Vector2.ONE / 2
	if player:
		uv = MathGame.get_screen_uv_from_node(player).clamp(Vector2.ZERO, Vector2.ONE)
	efeitoTimeStop.set("shader_parameter/player", uv)

	if start:
		colorInvertido.visible = true
		animator.play("Time Stop")
	else:
		#colorBase.visible = true
		paused_transition = true
		animator.play_backwards("Time Stop")
	
	await animator.animation_finished
	paused_transition = false
	
	if start:
		pass
		#colorBase.visible = false
	else:
		colorInvertido.visible = false
