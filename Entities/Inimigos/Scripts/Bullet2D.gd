extends CharacterBody2D
class_name Bullet2D

@onready var anim: AnimatedSprite2D = $anim

@export var speed: float = 120.0

var direction: Vector2 = Vector2.LEFT

func _init() -> void:
	SpawnManager.add_objeto_in_cache(self)
	add_to_group("Projectiles")

func _physics_process(_delta: float) -> void:
	velocity = speed * direction.normalized()
	
	if direction.x < 0.0:
		anim.flip_h = true
	else:
		anim.flip_h = false
	
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
