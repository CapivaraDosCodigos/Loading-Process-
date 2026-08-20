extends ColorRect

@onready var resume_button: Button = $VBoxContainer/ResumeButton

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not Game.is_paused_force:
		if not visible:
			visible = true
			get_tree().paused = true
			resume_button.grab_focus()
		else:
			resume_button.pressed.emit()

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_quit_button_pressed() -> void:
	get_tree().quit()
