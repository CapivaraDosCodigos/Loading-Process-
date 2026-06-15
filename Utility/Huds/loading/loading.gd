extends ColorRect

@onready var progress_bar: ProgressBar = %Progress
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog

var time: float = 0.0
var progress: float = 1.0
var pop: bool = false

func _ready() -> void:
	%Start_Button.focus_mode = Control.FocusMode.FOCUS_ALL
	%Start_Button.grab_focus()

func _process(delta: float) -> void:
	time += delta
	
	if time > progress and progress_bar.value < 75.0:
		progress_bar.value += progress
		time = progress
		progress = float(randi_range(1, 9))

func _on_start_button_pressed() -> void:
	Global.start_game(0)
	#confirmation_dialog.show()
	#confirmation_dialog.grab_focus()

func _on_confirmation_dialog_canceled() -> void:
	confirmation_dialog.hide()
	%Start_Button.grab_focus()

func _on_confirmation_dialog_confirmed() -> void:
	confirmation_dialog.show()
	Global.start_game(0)
