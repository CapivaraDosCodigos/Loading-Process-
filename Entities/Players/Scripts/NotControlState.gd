extends State

@export var gravity: bool = false

func physics_update(delta: float) -> void:
	if owner is Player2D:
		if gravity:
			owner.apply_gravity(delta)
