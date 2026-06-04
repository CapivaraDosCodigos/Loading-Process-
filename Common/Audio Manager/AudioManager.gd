extends Node

var players: Dictionary[AudioGame.Type, AudioPlayer] = {}

func _ready() -> void:
	for type: AudioGame.Type in AudioGame.Type.values():
		if not players.has(type):
			var player: AudioPlayer = AudioPlayer.new()
			add_child(player)
			players[type] = player

func play(type: AudioGame.Type, stream: AudioStream, volume: float, from_position: float = 0.0) -> AudioPlayer:
	var player: AudioPlayer = players[type]
	if not player:
		push_warning("Player não encontrado: %s" % type)
		return null
	
	player.play_audio(stream, volume, from_position)
	
	return player

func play_insurance(type: int, stream: AudioStream, volume: float, from_position: float = 0.0) -> AudioPlayer:
	var player: AudioPlayer = players[type]
	if not player:
		push_warning("Player não encontrado: %s" % type)
		return null
	
	if not player.is_playing_audio():
		player.play_audio(stream, volume, from_position)
	
	return player

func stop(type: AudioGame.Type) -> AudioPlayer:
	var player: AudioPlayer = players[type]
	if player:
		player.stop_audio()
		
	return player

func set_volume(type: AudioGame.Type, value: float) -> AudioPlayer:
	var player: AudioPlayer = players[type]
	if player:
		player.volume_0_100 = value
		
	return player

func set_loop(type: AudioGame.Type, value: bool) -> AudioPlayer:
	var player: AudioPlayer = players[type]
	if player:
		player.loop = value
		
	return player

func set_pitch_random(type: AudioGame.Type, value: bool, min_pitch: float = 0.8, max_pitch: float = 1.2) -> AudioPlayer:
	var player: AudioPlayer = players[type]
	if player:
		player.pitch_random = value
		player.pitch_random_min = min_pitch
		player.pitch_random_max = max_pitch
	
	return player

func stop_all() -> void:
	for player: AudioPlayer in players.values():
		player.stop_audio()

func set_volume_all(value: float) -> void:
	for player: AudioPlayer in players.values():
		player.volume_0_100 = value

func is_playing(type: AudioGame.Type) -> bool:
	var player: AudioPlayer = players[type]
	return player and player.is_playing_audio()
