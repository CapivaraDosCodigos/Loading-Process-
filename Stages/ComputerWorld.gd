extends Area2D

@onready var texture: Sprite2D = $Texture

@export_file_path("*.tscn*") var world_path: String
@export var maker: Marker2D

var is_anim: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if get_overlapping_bodies().size() > 0:
		texture.show()
		
		if event.is_action_pressed("Interect") and not is_anim:
			_start_animetion()
			
	else:
		texture.hide()

func _start_animetion() -> void:
	is_anim = true
	var player: Player2D = ManagerGame.player
	var tween: Tween = create_tween()
	var duration: float = (player.global_position.distance_to(maker.global_position) * 4.0) / player.speed
	tween.tween_property(player, "global_position", maker.global_position, duration)
	tween.finished.connect(_finished)
	
func _finished() -> void:
	await get_tree().create_timer(2.0, false).timeout
	SceneManager.load_scene(world_path, true, "transition_2")
