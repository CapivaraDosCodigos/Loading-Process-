extends CanvasLayer
class_name HudManager

@onready var coin_label: Label = $Control/Container/CoinContainer/CoinLabel
@onready var score_label: Label = $Control/Container/ScoreContainer/ScoreLabel
@onready var counter_life_label: Label = $Control/Container/LifeContainer/CounterLifeLabel
@onready var fps_label: Label = $Control/Container/FPSLabel

func _ready() -> void:
	EventBus.update_coins.connect(_on_update_coins)
	EventBus.update_player_life.connect(_on_update_player_life)
	EventBus.update_score.connect(_on_update_score)
	
	coin_label.text = str("%04d" % EventBus.coins)
	score_label.text = str("%06d" % EventBus.score)
	counter_life_label.text = str(EventBus.player_life)

func _process(_delta: float) -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _on_update_coins() -> void:
	coin_label.text = str("%04d" % EventBus.coins)

func _on_update_player_life() -> void:
	counter_life_label.text = str(EventBus.player_life)

func _on_update_score() -> void:
	score_label.text = str("%06d" % EventBus.score)
