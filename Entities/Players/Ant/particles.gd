extends GPUParticles2D
class_name Particles2D

func emit(dir: Vector2) -> void:
	restart()
	set_direction(dir)
	emitting = true

func set_direction(dir: Vector2) -> void:
	process_material.set_deferred("direction", Vector3(dir.x, dir.y, 0.0))
