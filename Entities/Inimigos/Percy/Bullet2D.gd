extends CharacterBody2D
class_name Bullet2D

@export var move_speed: float = 120.0
@onready var anim: AnimatedSprite2D = $anim
var take_damage_force: bool = true

var direction: int = 1

func _ready() -> void:
	ManagerGame.time_stop.connect(_stop)
	ManagerGame.time_play.connect(_play)
	if ManagerGame.is_paused:
		_stop()

func _stop() -> void:
	set_physics_process(false)
	anim.pause()

func _play() -> void:
	set_physics_process(true)
	anim.play()

func _physics_process(_delta: float) -> void:
	velocity.x = move_speed * direction
	move_and_slide()

func set_direction(dir: int) -> void:
	direction = dir
	if dir < 0:
		anim.flip_h = true
	else:
		anim.flip_h = false

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
