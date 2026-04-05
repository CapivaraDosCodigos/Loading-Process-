extends Node

enum AudioType {
	MUSIC_1 = 0,
	MUSIC_2 = 1,
	SFX_1 = 2,
	SFX_2 = 3,
	SFX_3 = 4,
	MENU = 5 }

var players: Dictionary[AudioType, AudioPlayer] = {}

func _ready() -> void:
	for type: AudioType in AudioType.values():
		if not players.has(type):
			var player: AudioPlayer = AudioPlayer.new()
			add_child(player)
			players[type] = player

func play(type: AudioType, stream: AudioStream, volume: float = 100.0, loop: bool = false) -> void:
	var player: AudioPlayer = players.get(type)
	if not player:
		push_warning("Player não encontrado: %s" % type)
		return
	
	player.volume_0_100 = volume
	player.loop = loop
	player.play_audio(stream)

func play_insurance(type: AudioType, stream: AudioStream, volume: float = 100.0, loop: bool = false) -> void:
	var player: AudioPlayer = players.get(type)
	if not player:
		push_warning("Player não encontrado: %s" % type)
		return
		
	if player.is_playing_audio() and player.stream == stream:
		return
	
	player.volume_0_100 = volume
	player.loop = loop
	player.play_audio(stream)

func stop(type: AudioType) -> void:
	var player: AudioPlayer = players.get(type)
	if player:
		player.stop_audio()

func stop_all() -> void:
	for player: AudioPlayer in players.values():
		player.stop_audio()

func set_volume(type: AudioType, value: float) -> void:
	var player: AudioPlayer = players.get(type)
	if player:
		player.volume_0_100 = value

func set_volume_all(value: float) -> void:
	for player: AudioPlayer in players.values():
		player.volume_0_100 = value

func is_playing(type: AudioType) -> bool:
	var player: AudioPlayer = players.get(type)
	return player and player.is_playing_audio()
