extends MarginContainer

@onready var coin_label: Label = %CoinLabel
@onready var score_bar: ProgressBar = %ScoreBar
@onready var counter_life_bar: TextureProgressBar = %CounterLifeLabel
@onready var fps_label: Label = %FPSLabel

func _ready() -> void:
	coin_label.text = str("%04d" % Game.coins)
	score_bar.value = Game.score
	counter_life_bar.value = Game.player_life

func _process(_delta: float) -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	coin_label.text = str("%04d" % Game.coins)
	counter_life_bar.value = Game.player_life
	score_bar.value = Game.score
