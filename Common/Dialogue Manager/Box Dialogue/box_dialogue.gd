extends MarginContainer
class_name BoxDialogue

@onready var label: Label = $LabelMargin/Label
@onready var letter_timer_display: Timer = $LetterTimerDisplay

const MAX_WIDTH: int = 256

var text: String = ""
var letter_index: int = 0

var letter_display_timer: float = 0.07
var space_display_timer: float = 0.05
var punctuaction_display_timer: float = 0.02

signal text_display_finished()

func text_display(text_to_display: String) -> void:
	text = text_to_display
	label.text = text_to_display
	
	await resized
	
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized
		await resized
		
		custom_minimum_size.y = size.y
		
	global_position.x -= size.x / 2.0
	global_position.y -= size.y + 24.0
	label.text = ""
	display_letter()

func display_letter() -> void:
	label.text += text[letter_index]
	letter_index += 1
	
	if letter_index >= text.length():
		text_display_finished.emit()
		return
	
	match text:
		"?", "!", ",", ".":
			letter_timer_display.start(punctuaction_display_timer)
		" ":
			letter_timer_display.start(space_display_timer)
		_:
			letter_timer_display.start(letter_display_timer)

func _on_letter_timer_display_timeout() -> void:
	display_letter()
