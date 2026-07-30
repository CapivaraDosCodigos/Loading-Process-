extends Resource
class_name Game

enum Item { Lampada, ScalingEquipment, Dash }

const FILE_EXTENSION: String = ".tres"
const SAVE_PATH: String = "res://save_slot_%d" + FILE_EXTENSION
const SAVE_CONFIG: String = "res://config.txt" #cfg

@export_file_path("*.tscn*") var levels: Array[String] = []

static func get_input() -> Vector2:
	var input_x: float = Input.get_axis("ui_left", "ui_right")
	var input_y: float= Input.get_axis("ui_up", "ui_down")
	
	if !is_equal_approx(input_x, 0.0) and abs(input_x) > 0.5:
		input_x = abs(input_x) / input_x
	else:
		input_x = 0.0
	
	if !is_equal_approx(input_y, 0.0) and abs(input_y) > 0.5:
		input_y = abs(input_y) / input_y
	else:
		input_y = 0.0
	
	return Vector2(input_x, input_y)

#static func get_input() -> Vector2:
	#var input_x: float= Input.get_axis("ui_left", "ui_right")
	#var input_y: float= Input.get_axis("ui_up", "ui_down")
	#
	#if !is_equal_approx(input_x, 0.0) and abs(input_x) > 0.5:
		#input_x = abs(input_x) / input_x
	#else:
		#input_x = 0.0
	#
	#if !is_equal_approx(input_y, 0.0) and abs(input_y) > 0.5:
		#input_y = abs(input_y) / input_y
	#else:
		#input_y = 0.0
	#
	#return Vector2(input_x, input_y)

static func is_input_horizontal() -> bool:
	var pressed: bool = Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")
	var released: bool = Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left")
	return pressed or released
