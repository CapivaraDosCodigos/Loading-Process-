@tool
extends AudioStreamPlayer2D
class_name AudioPlayer2D

@export var volume: float = 100.0:
	set(value):
		volume = clamp(value, 0.0, 100.0)
		volume_db = linear_to_db(volume / 100.0)
@export var loop: bool = false
@export var pitch_random: bool = false
@export var min_pitch: float = 0.8
@export var max_pitch: float = 1.2

func _ready() -> void:
	finished.connect(_on_finished)

func _apply_loop() -> void:
	if stream is AudioStreamOggVorbis:
		stream.loop = loop
		
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED

func _on_finished() -> void:
	pass

func play_audio(from_position: float = 0.0) -> void:
	_apply_loop()
	
	if pitch_random:
		pitch_scale = randf_range(min_pitch, max_pitch)
	else:
		pitch_random = 1.0
	
	play(from_position)

func play_stream(stream_p: AudioStream, from_position: float = 0.0) -> void:
	if not stream_p:
		return
	
	stream = stream_p
	
	_apply_loop()
	
	if pitch_random:
		pitch_scale = randf_range(0.8, 1.2)
	else:
		pitch_random = 1.0
	
	play(from_position)
