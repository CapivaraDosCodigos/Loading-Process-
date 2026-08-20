extends Control
## Extrai (ou fakeia) amplitude, frequency e intensity a partir de um AudioStreamPlayer,
## atualizando automaticamente a cada frame. Pensado para alimentar shaders/texturas
## reativas ao áudio.

@export var use_real_audio: bool = true
@export var bus_name: String = "Music"          # nome do bus com o Spectrum Analyzer
@export var audio_player: AudioStreamPlayer     # arraste o player no Inspector

# Variáveis finais, sempre normalizadas entre 0.0 e 1.0 (prontas pra mandar pro shader)
var amplitude: float = 0.0:
	set(value):
		amplitude = value
		material.set("shader_parameter/amplitude", amplitude)
var frequency: float = 0.0:
	set(value):
		frequency = value
		material.set("shader_parameter/frequency", frequency)
var intensity: float = 0.0:
	set(value):
		intensity = value
		material.set("shader_parameter/intensity", intensity)

var _spectrum: AudioEffectSpectrumAnalyzerInstance
var _time: float = 0.0
var _smooth_speed: float = 8.0

const FREQ_BANDS = [
	{"name": "bass",  "min": 20.0,   "max": 250.0},
	{"name": "mid",   "min": 250.0,  "max": 2000.0},
	{"name": "treble","min": 2000.0, "max": 8000.0},
]

func _ready() -> void:
	if use_real_audio:
		_setup_spectrum_analyzer()

func _setup_spectrum_analyzer() -> void:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		push_warning("Bus '%s' não encontrado. Crie o bus e adicione o efeito Spectrum Analyzer, ou desative use_real_audio." % bus_name)
		use_real_audio = false
		return

	for effect_idx in AudioServer.get_bus_effect_count(bus_idx):
		var effect: AudioEffect = AudioServer.get_bus_effect(bus_idx, effect_idx)
		if effect is AudioEffectSpectrumAnalyzer:
			_spectrum = AudioServer.get_bus_effect_instance(bus_idx, effect_idx)
			return

	push_warning("Nenhum AudioEffectSpectrumAnalyzer encontrado no bus '%s'." % bus_name)
	use_real_audio = false

func _process(delta: float) -> void:
	_time += delta

	var target_amp: float
	var target_freq: float
	var target_intensity: float

	if use_real_audio and _spectrum:
		target_amp = _get_real_amplitude()
		target_freq = _get_real_frequency()
		target_intensity = _get_real_intensity()
	else:
		target_amp = _fake_amplitude()
		target_freq = _fake_frequency()
		target_intensity = _fake_intensity()

	var t: float = 1.0 - exp(-_smooth_speed * delta)
	amplitude = lerp(amplitude, target_amp, t)
	frequency = lerp(frequency, target_freq, t)
	intensity = lerp(intensity, target_intensity, t)

func _get_real_amplitude() -> float:
	# Soma a magnitude em todo o espectro audível como "volume geral"
	var mag: Vector2 = _spectrum.get_magnitude_for_frequency_range(20.0, 8000.0)
	var db: float = linear_to_db(mag.length())
	# normaliza de um range de dB razoável (-60 a 0) pra 0..1
	return clamp(inverse_lerp(-60.0, 0.0, db), 0.0, 1.0)

func _get_real_frequency() -> float:
	# Descobre qual faixa (bass/mid/treble) está mais forte e mapeia pra 0..1
	var strongest_idx: int = 0
	var strongest_val: float = -INF
	for i in FREQ_BANDS.size():
		var band: Dictionary = FREQ_BANDS[i]
		var mag: Vector2 = _spectrum.get_magnitude_for_frequency_range(band.min, band.max)
		var val: float = mag.length()
		if val > strongest_val:
			strongest_val = val
			strongest_idx = i
	return float(strongest_idx) / float(FREQ_BANDS.size() - 1)

func _get_real_intensity() -> float:
	# Intensity = combinação de pico + energia total, boa pra "força" do efeito
	var mag: Vector2 = _spectrum.get_magnitude_for_frequency_range(20.0, 8000.0)
	var peak_db: float = AudioServer.get_bus_peak_volume_left_db(AudioServer.get_bus_index(bus_name), 0)
	var energy: float = clamp(inverse_lerp(-60.0, 0.0, linear_to_db(mag.length())), 0.0, 1.0)
	var peak: float = clamp(inverse_lerp(-60.0, 0.0, peak_db), 0.0, 1.0)
	return clamp((energy + peak) * 0.5, 0.0, 1.0)

# ------------------------------------------------------------------
# MODO FAKE — sem áudio real, só oscilação orgânica no tempo
# ------------------------------------------------------------------

func _fake_amplitude() -> float:
	# combina duas senoides com frequências diferentes pra parecer menos "robótico"
	var v: float = (sin(_time * 1.3) * 0.5 + 0.5) * 0.7 + (sin(_time * 3.7) * 0.5 + 0.5) * 0.3
	return clamp(v, 0.0, 1.0)

func _fake_frequency() -> float:
	var v: float = (sin(_time * 0.6 + 1.5) * 0.5 + 0.5)
	return clamp(v, 0.0, 1.0)

func _fake_intensity() -> float:
	var v: float = (sin(_time * 2.1 + 0.7) * 0.5 + 0.5) * 0.6 + (sin(_time * 0.4) * 0.5 + 0.5) * 0.4
	return clamp(v, 0.0, 1.0)
