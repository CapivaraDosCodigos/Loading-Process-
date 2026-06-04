extends AudioStreamPlayer
class_name AudioPlayer

var volume_0_100: float = 100.0:
	set(value):
		volume_0_100 = clamp(value, 0.0, 100.0)
		volume_db = linear_to_db(volume_0_100 / 100.0)
var loop: bool = false
var pitch_random: bool = false

var pitch_random_min: float = 0.8
var pitch_random_max: float = 1.2

func _ready() -> void:
	finished.connect(_on_finished)

func _apply_loop() -> void:
	if stream is AudioStreamOggVorbis:
		stream.loop = loop
		
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED

func _on_finished() -> void:
	pass

func play_audio(stream_p: AudioStream, volume_p: float, from_position: float = 0.0) -> AudioPlayer:
	if not stream_p:
		return self
	
	stream = stream_p
	volume_0_100 = volume_p
	
	_apply_loop()
	
	if pitch_random:
		pitch_scale = randf_range(pitch_random_min, pitch_random_max)
	else:
		pitch_random = 1.0
	
	play(from_position)
	return self

func stop_audio() -> AudioPlayer:
	stop()
	
	return self

func set_volume(value: float) -> AudioPlayer:
	volume_0_100 = value
	return self

func set_loop(value: bool)  -> AudioPlayer:
	loop = value
	return self

func set_pitch_random(value: bool, min_pitch: float = 0.8, max_pitch: float = 1.2) -> AudioPlayer:
	pitch_random = value
	pitch_random_min = min_pitch
	pitch_random_max = max_pitch
	return self

func is_playing_audio() -> bool:
	return playing and stream
