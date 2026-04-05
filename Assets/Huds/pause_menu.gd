extends CanvasLayer

@onready var resume_button: Button = $VBoxContainer/ResumeButton

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_cancel") and not visible:
		visible = true
		get_tree().paused = true
		resume_button.grab_focus()

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_quit_button_pressed() -> void:
	get_tree().quit()
