class_name AudioAnalyzer
extends Node

## Analisa o áudio em três bandas e expõe valores suavizados de 0..1.
## Graves: 20-250 Hz
## Médios: 250-2000 Hz
## Agudos: 2000-10000 Hz

var analyzer: AudioEffectSpectrumAnalyzerInstance

var bass: float = 0.0
var mid: float = 0.0
var treble: float = 0.0
var overall: float = 0.0

@export var smoothing: float = 8.0


func _ready() -> void:
	var bus_index: int = AudioServer.get_bus_index("Music")

	if bus_index == -1:
		AudioServer.add_bus()
		bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(bus_index, "Music")

	var effect: AudioEffectSpectrumAnalyzer = AudioEffectSpectrumAnalyzer.new()
	effect.buffer_length = 0.2
	effect.fft_size = AudioEffectSpectrumAnalyzer.FFT_SIZE_1024

	AudioServer.add_bus_effect(bus_index, effect, 0)

	analyzer = AudioServer.get_bus_effect_instance(
		bus_index,
		0
	) as AudioEffectSpectrumAnalyzerInstance


func _process(delta: float) -> void:
	if analyzer == null:
		return

	var b: float = _read_band(20.0, 250.0)
	var m: float = _read_band(250.0, 2000.0)
	var t: float = _read_band(2000.0, 10000.0)

	var smooth_factor: float = clamp(
		smoothing * delta,
		0.0,
		1.0
	)

	bass = lerp(bass, b, smooth_factor)
	mid = lerp(mid, m, smooth_factor)
	treble = lerp(treble, t, smooth_factor)

	overall = (bass + mid + treble) / 3.0


func _read_band(low_hz: float, high_hz: float) -> float:
	if analyzer == null:
		return 0.0

	var magnitude: Vector2 = analyzer.get_magnitude_for_frequency_range(
		low_hz,
		high_hz,
		AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_MAX
	)

	var energy: float = magnitude.length()

	# Sensibilidade diferente para permitir visualizar
	# melhor as frequências mais fracas.
	var normalized: float = (energy - 0.005) * 8.0

	return clamp(normalized, 0.0, 1.0)