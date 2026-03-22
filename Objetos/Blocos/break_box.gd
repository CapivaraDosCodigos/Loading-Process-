extends StaticBody2D
class_name BreakBox2D

static var moeda: PackedScene:
	get():
		if not moeda:
			moeda = load("uid://chbi5u53x56ed")
		return moeda

static var box_pieces: PackedScene:
	get():
		if not box_pieces:
			box_pieces = load("uid://dah8su763jcgc")
		return box_pieces

@onready var animation: AnimationPlayer = $Animation

@export_file("*.png*", "*.svg*") var pieces: PackedStringArray = []
@export var hitpoints: int = 3

var impuse: int = 100

func break_sprites() -> void:
	if hitpoints > 0:
		hitpoints -= 1
		create_moeda()
		animation.play("hit")
	else:
		create_moeda()
		for piece in pieces.size():
			var instaciente: RigidBody2D = box_pieces.instantiate()
			get_parent().add_child(instaciente)
			instaciente.get_node("Texture").texture = load(pieces[piece])
			instaciente.global_position = global_position
			instaciente.apply_impulse(Vector2(randi_range(-impuse, impuse), randi_range(-impuse, -impuse * 2)))
		queue_free()

func create_moeda() -> void:
	var coin: RigidBody2D = moeda.instantiate()
	coin.global_position = global_position - Vector2(0.0, 8.0)
	get_parent().add_child.call_deferred(coin)
	coin.apply_impulse(Vector2(randf_range(-50, 50), -200))
