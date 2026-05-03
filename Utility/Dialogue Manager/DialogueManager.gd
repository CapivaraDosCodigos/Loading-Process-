extends Node

@onready var box_dialogue_scene: PackedScene = preload("uid://by00covma4ayu")
var messagem_lines: Array[String] = []
var current_line: int = 0

var dialogue_box: BoxDialogue
var current_actor: Node2D

var dialogue_box_position: Vector2 = Vector2.ZERO

var is_messagem_active: bool = false
var can_advance_messagem: bool = false
var is_last_line: bool = false

func start_messagem(position: Vector2, lines: Array[String], new_actor: Node2D) -> void:
	if is_messagem_active:
		return
	
	messagem_lines = lines
	dialogue_box_position = position
	current_actor = new_actor
	
	show_text()
	is_messagem_active = true

func show_text() -> void:
	dialogue_box = box_dialogue_scene.instantiate()
	dialogue_box.text_display_finished.connect(_on_all_texts_displayed)
	dialogue_box.global_position = dialogue_box_position
	
	get_tree().current_scene.add_child(dialogue_box)
	
	is_last_line = (current_line == messagem_lines.size() - 1)
	dialogue_box.text_display(messagem_lines[current_line])
	can_advance_messagem = false

func _on_all_texts_displayed() -> void:
	if is_last_line:
		can_advance_messagem = false
		
		await get_tree().create_timer(2.0, false).timeout
		
		if dialogue_box:
			dialogue_box.queue_free()
		
		current_line = 0
	else:
		can_advance_messagem = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interect") and is_messagem_active and can_advance_messagem:
		if dialogue_box:
			dialogue_box.queue_free()
		
		current_line += 1
		show_text()
