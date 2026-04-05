extends Node

var inGame: bool = true

@onready var controls: CanvasLayer = $Controls
@onready var game_hud: CanvasLayer = $GameHUD

#region InGame

@onready var efeitoTimeStop: ShaderMaterial = %Invertido.material
@onready var colorInvertido: ColorRect = %Invertido
@onready var colorBase: ColorRect = %Base
@onready var animator: AnimationPlayer = $Animator

signal time_stop
signal time_play
signal update_coins
signal update_player_life
signal update_score

var is_paused: bool = false
var paused_transition: bool = false

var coins: int = 0:
	set(value):
		coins = value
		update_coins.emit()
var score: int = 0:
	set(value):
		score = value
		update_score.emit()
var player_life: int = 3:
	set(value):
		player_life = value
		update_player_life.emit()

var player: Player2D
var check_point: Node2D

func respawn_player() -> void:
	if check_point:
		player.global_position = check_point.global_position

func time_stop_event() -> void:
	is_paused = true
	time_stop.emit()

	await _apply_time_effect(true)

	await get_tree().create_timer(9.0).timeout

	await _apply_time_effect(false)

	time_play.emit()
	is_paused = false

func _apply_time_effect(start: bool) -> void:
	var uv: Vector2 = _get_screen_uv_from_node(player).clamp(Vector2.ZERO, Vector2.ONE)
	efeitoTimeStop.set("shader_parameter/player", uv)

	if start:
		colorInvertido.visible = true
		animator.play("Time Stop")
	else:
		colorBase.visible = true
		animator.play_backwards("Time Stop")
	
	paused_transition = true
	await animator.animation_finished
	paused_transition = false
	
	if start:
		colorBase.visible = false
	else:
		colorInvertido.visible = false

func _get_screen_uv_from_node(node: Node2D) -> Vector2:
	if not node:
		return Vector2.ZERO
	
	var viewport: Viewport = node.get_viewport()
	var camera: Camera2D = viewport.get_camera_2d()
	
	if not camera:
		push_warning("Sem Camera2D ativa")
		return Vector2.ZERO
	
	var global_pos: Vector2 = node.global_position

	var screen_pos: Vector2 = get_viewport().get_canvas_transform() * global_pos
	
	var size: Vector2 = viewport.get_visible_rect().size

	var uv: Vector2 = screen_pos / size
	
	return uv

#endregion
