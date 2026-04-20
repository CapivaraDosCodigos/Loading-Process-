extends CanvasLayer
class_name LoadScreen

## Tela de carregamento com suporte a múltiplos tipos de transição baseados em shader

## Emitido quando a animação inicial da tela termina e o carregamento pode começar
signal loading_screen_ready

## AnimationPlayer responsável por tocar as animações de entrada e saída
@export var animation: AnimationPlayer

## Define o tipo de transição utilizado (transition_1 até transition_6)
## transition_1: efeito diamante pixelado crescente
## transition_2: abertura circular a partir do jogador
## transition_3: abertura circular a partir do centro da tela
## transition_4: corte vertical tipo cortina
## transition_5: corte horizontal tipo cortina
## transition_6: linhas horizontais animadas em direções opostas
var type_transition: String = "transition_1"

func _ready() -> void:
	animation.play(type_transition)
	await animation.animation_finished
	loading_screen_ready.emit()

## Atualiza o progresso do carregamento, podendo ser usado para UI
func _on_progress_changed(_new_value: float) -> void:
	pass

## Executa a animação de saída e remove a tela após o carregamento
func _on_load_finished() -> void:
	animation.play_backwards(type_transition)
	await animation.animation_finished
	queue_free()
