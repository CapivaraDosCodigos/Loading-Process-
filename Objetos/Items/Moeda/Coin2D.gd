extends Area2D
class_name Coin2D

static var audio: AudioStream = preload("uid://d32eu2b040w82")

@onready var animated: AnimatedSprite2D = $Animated
@onready var collision: CollisionShape2D = $Collision

@export var score_mode: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player2D:
		add_moeda.call_deferred(body)

func add_moeda(_body: Player2D) -> void:
	animated.play("End")
	
	collision.queue_free.call_deferred()
	
	if score_mode:
		Game.score += 1
	else:
		Game.coins += 1
		AudioManager.set_loop(AudioGame.SFX_ITEMS, false).set_pitch_random(true, 0.95, 1.05)
		AudioManager.play(AudioGame.SFX_ITEMS, audio, 60.0)
	
	var parent: Node = get_parent()
	if parent is RigidBody2D:
		parent.freeze = true

func _on_animated_animation_finished() -> void:
	if get_parent() is RigidBody2D:
		get_parent().queue_free()
	else:
		queue_free()
