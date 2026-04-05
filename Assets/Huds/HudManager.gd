extends Control

@onready var coin_label: Label = $Container/CoinContainer/CoinLabel
@onready var score_label: Label = $Container/ScoreContainer/ScoreLabel
@onready var counter_life_label: Label = $Container/LifeContainer/CounterLifeLabel
@onready var fps_label: Label = $Container/FPSLabel

func _ready() -> void:
	Global.update_coins.connect(_on_update_coins)
	Global.update_player_life.connect(_on_update_player_life)
	Global.update_score.connect(_on_update_score)
	
	coin_label.text = str("%04d" % Global.coins)
	score_label.text = str("%06d" % Global.score)
	counter_life_label.text = str(Global.player_life)

func _process(_delta: float) -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _on_update_coins() -> void:
	coin_label.text = str("%04d" % Global.coins)

func _on_update_player_life() -> void:
	counter_life_label.text = str(Global.player_life)

func _on_update_score() -> void:
	score_label.text = str("%06d" % Global.score)
