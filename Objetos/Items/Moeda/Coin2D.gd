extends Area2D
class_name Coin2D

@onready var animated: AnimatedSprite2D = $Animated
@onready var collision: CollisionShape2D = $Collision

@export var score_mode: bool = false

static var audio: AudioStream = preload("uid://d32eu2b040w82")

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

func _on_body_entered(body: Node2D) -> void:
	if body is Player2D:
		add_moeda.call_deferred(body)

func add_moeda(body: Player2D) -> void:
	animated.play("End")
	
	collision.queue_free.call_deferred()
	
	if score_mode:
		Global.score += 1
	else:
		Global.coins += 1
		body.play_audio("Items", audio, 90.0, false, false)
	
	var parent: Node = get_parent()
	if parent is RigidBody2D:
		parent.freeze = true

func _on_animated_animation_finished() -> void:
	if get_parent() is RigidBody2D:
		get_parent().queue_free()
	else:
		queue_free()
