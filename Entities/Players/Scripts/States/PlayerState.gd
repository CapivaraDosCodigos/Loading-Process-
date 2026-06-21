class_name PlayerState extends State

const IDLE = "Idle"
const RUN = "Run"
const JUMP = "Jump"
const WALL_SLIDE = "WallSlide"
const DASH = "Dash"

var player: Player2D

func _ready() -> void:
	await owner.ready
	player = owner as Player2D
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")
