extends MarginContainer

@onready var coin_label: Label = %CoinLabel
@onready var score_label: Label = %ScoreLabel
@onready var counter_life_label: TextureProgressBar = %CounterLifeLabel
@onready var fps_label: Label = %FPSLabel

func _ready() -> void:
	coin_label.text = str("%04d" % Global.coins)
	score_label.text = str("%06d" % Global.score)
	counter_life_label.value = Global.player_life

func _process(_delta: float) -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	coin_label.text = str("%04d" % Global.coins)
	counter_life_label.value = Global.player_life
	score_label.text = str("%06d" % Global.score)
	counter_life_label.use_parent_material = 0.75 < (counter_life_label.value / counter_life_label.max_value)
