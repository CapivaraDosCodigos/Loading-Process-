extends StaticBody2D
class_name BreakBox2D

static var moeda: PackedScene = preload("uid://chbi5u53x56ed")
static var audio_1: AudioStream = preload("uid://cgrtywsavmewq")
static var audio_2: AudioStream = preload("uid://c6v0j6km0b3gp")
static var box_pieces: PackedScene = preload("uid://dah8su763jcgc")

@onready var animation: AnimationPlayer = $Animation

@export_file("*.png*", "*.svg*") var pieces: PackedStringArray = []
@export var hitpoints: int = 3

var impuse: int = 100

func break_sprites(body: Player2D) -> void:
	if hitpoints > 0:
		hitpoints -= 1
		create_moeda()
		animation.play("hit")
		body.play_audio("SoundEffect", audio_2, 100.0)
	
	else:
		create_moeda()
		for piece in pieces.size():
			var instaciente: RigidBody2D = box_pieces.instantiate()
			get_parent().add_child(instaciente)
			instaciente.get_node("Texture").texture = load(pieces[piece])
			instaciente.global_position = global_position
			instaciente.apply_impulse(Vector2(randi_range(-impuse, impuse), randi_range(-impuse, -impuse * 2)))
		
		body.play_audio("SoundEffect", audio_1, 100.0)
		queue_free()

func create_moeda() -> void:
	var coin: RigidBody2D = moeda.instantiate()
	coin.global_position = global_position - Vector2(0.0, 8.0)
	get_parent().add_child.call_deferred(coin)
	coin.apply_impulse(Vector2(randf_range(-50, 50), -200))
