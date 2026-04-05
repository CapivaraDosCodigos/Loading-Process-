extends Area2D
class_name Coin2D

@onready var animated: AnimatedSprite2D = $Animated
@onready var collision: CollisionShape2D = $Collision

static var audio: AudioStream:
	get():
		if not audio:
			audio = preload("uid://d32eu2b040w82")
		return audio

func _ready() -> void:
	Global.time_stop.connect(_stop)
	Global.time_play.connect(_play)
	if Global.is_paused:
		_stop()

func _stop() -> void:
	var parent: Node = get_parent()
	if parent is RigidBody2D:
		parent.freeze = true
	animated.pause()

func _play() -> void:
	var parent: Node = get_parent()
	if parent is RigidBody2D:
		parent.freeze = false
	animated.play()

func _on_body_entered(_body: Node2D) -> void:
	add_moeda.call_deferred()

func add_moeda() -> void:
	animated.play("End")
	
	collision.queue_free.call_deferred()
	
	Global.coins += 1
	AudioManager.play(AudioManager.AudioType.SFX_1,
	audio, 50, false)
	
	var parent: Node = get_parent()
	if parent is RigidBody2D:
		parent.freeze = true

func _on_animated_animation_finished() -> void:
	if get_parent() is RigidBody2D:
		get_parent().queue_free()
	else:
		queue_free()
