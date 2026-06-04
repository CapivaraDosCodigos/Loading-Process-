extends Node

const section: String = "CONFIG"

@onready var container_buttons: VBoxContainer = $MarginContainer/ContainerButtons
@onready var container_credits: VBoxContainer = $MarginContainer/ContainerCredits
@onready var container_saves: VBoxContainer = $MarginContainer/ContainerSaves
@onready var popup_error: VBoxContainer = $MarginContainer/PopupError
@onready var start_button: Button = %Start_Button
@onready var tvpixel_button: LinkButton = %TVPixel
@onready var slot_button: Button = %Slot_1
@onready var return_error_button: Button = %Return_Error_Button

func _ready() -> void:
	ManagerGame.hide_ui()
	Global.error_start.connect(_on_error_start)
	container_buttons.show()
	container_credits.hide()
	container_saves.hide()
	popup_error.hide()
	start_button.grab_focus()

func _on_start_button_pressed() -> void:
	container_buttons.hide()
	container_credits.hide()
	container_saves.show()
	popup_error.hide()
	
	slot_button.focus_mode = Control.FocusMode.FOCUS_ALL
	#await get_tree().process_frame
	slot_button.grab_focus()

func _on_credits_button_pressed() -> void:
	container_buttons.hide()
	container_credits.show()
	container_saves.hide()
	popup_error.hide()
	
	tvpixel_button.focus_mode = Control.FocusMode.FOCUS_ALL
	#await get_tree().process_frame
	tvpixel_button.grab_focus.call_deferred()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_return_button_pressed() -> void:
	container_buttons.show()
	container_credits.hide()
	container_saves.hide()
	popup_error.hide()
	
	start_button.focus_mode = Control.FocusMode.FOCUS_ALL
	#await get_tree().process_frame
	start_button.grab_focus()

func _on_slot_1_pressed() -> void:
	Global.start_game(1)

func _on_slot_2_pressed() -> void:
	Global.start_game(2)
 
func _on_slot_3_pressed() -> void:
	Global.start_game(3)

func _on_error_start() -> void:
	container_buttons.hide()
	container_credits.hide()
	container_saves.hide()
	popup_error.show()
	
	return_error_button.focus_mode = Control.FocusMode.FOCUS_ALL
	#await get_tree().process_frame
	return_error_button.grab_focus()

func _on_criar_novo_button_pressed() -> void:
	Save.delete_file(Game.SAVE_PATH % ManagerGame.current_slot)
	Global.start_game(ManagerGame.current_slot)
