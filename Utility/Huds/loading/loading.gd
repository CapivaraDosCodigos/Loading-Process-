extends ColorRect

@onready var progress_bar: ProgressBar = %Progress

var time: float = 0.0
var progress: float = 1.0

func _physics_process(delta: float) -> void:
	time += delta
	
	if time > progress and progress_bar.value < 75.0:
		progress_bar.value += progress
		time = progress
		progress = float(randi_range(1, 9))

func _on_start_button_pressed() -> void:
	if progress_bar.value < 75.0:
		OS.alert("Tem Certeza? Espere o carregamento", "Administrador")
	else:
		Global.start_game(0.0)
