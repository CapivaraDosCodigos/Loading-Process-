class_name PlayerState extends State

const IDLE = "Idle"
const RUN = "Run"
const JUMP = "Jump"
const WALL_SLIDE = "WallSlide"
const WALL_JUMP = "WallJump"
const DASH = "Dash"
const HURT = "Hurt"
const FALL = "Fall"

const PRE_JUMP = "Pre-Jump"
const POS_JUMP = "Pos-Jump"

var player: Player2D

func _init(owner: Player2D) -> void:
	player = owner as Player2D
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")

func is_active() -> bool:
	return player.state_machine.is_state(name)

func can_wall_slide() -> bool:
	var touching_wall: bool = player.ray_right.is_colliding() or player.ray_left.is_colliding()
	return not player.is_on_floor() and touching_wall and player.velocity.y > 0

func handle_dash()-> bool:
	if player.buffer_dash.is_interval() and player.dash_cooldown:
		finished.emit(DASH)
		return true
	return false

func handle_movement(_delta: float) -> void:
	pass
