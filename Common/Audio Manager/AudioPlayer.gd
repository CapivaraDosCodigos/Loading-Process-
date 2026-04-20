extends AudioStreamPlayer
class_name AudioPlayer

var volume_0_100: float = 100.0:
	set(value):
		volume_0_100 = clamp(value, 0.0, 100.0)
		volume_db = linear_to_db(volume_0_100 / 100.0)
var loop: bool = false
var pitch_random: bool = false

func _ready() -> void:
	finished.connect(_on_finished)

func _apply_loop() -> void:
	if stream is AudioStreamOggVorbis:
		stream.loop = loop
		
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED

func _on_finished() -> void:
	pass

func play_audio(stream_p: AudioStream, from_position: float = 0.0) -> void:
	if not stream_p:
		return
	
	self.stream = stream_p
	
	_apply_loop()
	
	if pitch_random:
		pitch_scale = randf_range(0.8, 1.2)
	else:
		pitch_random = 1.0
	
	play(from_position)

func stop_audio() -> void:
	stop()

func is_playing_audio() -> bool:
	return playing
