extends Resource
class_name Game

enum Item { Lampada, ScalingEquipment, Dash }

const FILE_EXTENSION: String = ".tres"
const SAVE_PATH: String = "res://save_slot_%d" + FILE_EXTENSION
const SAVE_CONFIG: String = "res://config.txt" #cfg

@export_file_path("*.tscn*") var levels: Array[String] = []
