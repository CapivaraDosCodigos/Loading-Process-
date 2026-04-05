extends AnimatableBody2D
class_name Platform2D

const WAIT_DURATION: float = 1.0

@export var move_speed: float = 3.0
@export var distance: float = 192.0
@export var move_horizonta: bool = false
@export var platform_center: int = 16

var follow: Vector2
var start_pos: Vector2
var platform_tween: Tween

func _ready() -> void:
	start_pos = position
	follow = start_pos
	_move_platform()
	Global.time_stop.connect(_stop)
	Global.time_play.connect(_play)

func _stop() -> void:
	set_physics_process(false)
	platform_tween.pause()

func _play() -> void:
	set_physics_process(true)
	platform_tween.play()

func _physics_process(_delta: float) -> void:
	position = position.lerp(follow, 0.5)

func _move_platform() -> void:
	var move_direction: Vector2 = Vector2.RIGHT * distance if move_horizonta else Vector2.UP * distance
	var duration: float = move_direction.length() / float(move_speed * platform_center)

	var target_pos: Vector2 = start_pos + move_direction

	platform_tween = create_tween().set_loops()
	platform_tween.tween_property(self, "follow", target_pos, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_delay(WAIT_DURATION)
	platform_tween.tween_property(self, "follow", start_pos, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_delay(WAIT_DURATION)
