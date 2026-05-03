extends Area2D
class_name DialogueArea

@onready var texture: Sprite2D = $Texture
@export var lines: Array[String] = []

var player_inside: bool = false

func _ready() -> void:
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interect") and player_inside:
		DialogueManager.start_messagem(global_position, lines, self)

func _on_player_entered(body: Node2D) -> void:
	if body is Player2D:
		player_inside = true
		texture.show()

func _on_player_exited(body: Node2D) -> void:
	if not body is Player2D:
		return
		
	player_inside = false
	texture.hide()
		
	if DialogueManager.current_actor == self:
		if DialogueManager.dialogue_box:
			DialogueManager.dialogue_box.queue_free()
		DialogueManager.is_messagem_active = false
		DialogueManager.current_line = 0
		
