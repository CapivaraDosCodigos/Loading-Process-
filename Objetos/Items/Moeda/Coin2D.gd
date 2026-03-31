extends Area2D
class_name Coin2D

@onready var animated: AnimatedSprite2D = $Animated
@onready var collision: CollisionShape2D = $Collision

func _ready() -> void:
	EventBus.time_stop.connect(_stop)
	EventBus.time_play.connect(_play)
	if EventBus.is_paused:
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
	
	EventBus.coins += 1
	
	var parent: Node = get_parent()
	if parent is RigidBody2D:
		parent.freeze = true

func _on_animated_animation_finished() -> void:
	if get_parent() is RigidBody2D:
		get_parent().queue_free()
	else:
		queue_free()
