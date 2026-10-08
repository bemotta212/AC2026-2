extends Node2D

const ENEMY_SCENE = preload("res://scripts/enemy.gd")

@onready var player: CharacterBody2D = $Player
@onready var music: AudioStreamPlayer = $Music
@onready var audio: AudioAnalyzer = $AudioAnalyzer
@onready var world: Node2D = $World

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var enemies: Array[BeatEnemy] = []
var particles: GPUParticles2D
var particle_material: ParticleProcessMaterial
var demo_playback: AudioStreamGeneratorPlayback
var demo_time: float = 0.0
var spawn_timer: float = 0.0


func _ready() -> void:
	rng.randomize()
	_setup_music_bus()
	_setup_particles()
	_setup_demo_audio()
	_spawn_initial_enemies()
	queue_redraw()


func _process(delta: float) -> void:
	spawn_timer += delta

	# Quanto maior a energia geral, maior a frequência de surgimento.
	var spawn_interval: float = lerp(2.4, 0.55, audio.overall)

	if spawn_timer >= spawn_interval and enemies.size() < 18:
		spawn_timer = 0.0
		_spawn_enemy()

	_update_particles()
	_update_demo_audio(delta)
	queue_redraw()


func _draw() -> void:
	# Fundo da arena.
	draw_rect(
		Rect2(0, 0, 1280, 720),
		Color(0.025, 0.03, 0.06)
	)

	# Grade.
	for x in range(40, 1241, 40):
		draw_line(
			Vector2(x, 40),
			Vector2(x, 680),
			Color(0.08, 0.11, 0.18),
			1.0
		)

	for y in range(40, 681, 40):
		draw_line(
			Vector2(40, y),
			Vector2(1240, y),
			Color(0.08, 0.11, 0.18),
			1.0
		)

	# Borda que pulsa com o grave.
	var glow: float = 2.0 + audio.bass * 8.0

	draw_rect(
		Rect2(30, 30, 1220, 660),
		Color(0.15, 0.65, 1.0, 0.35),
		false,
		glow
	)

	# Núcleo central reagindo aos graves.
	var radius: float = 45.0 + audio.bass * 55.0

	draw_circle(
		Vector2(640, 360),
		radius,
		Color(0.15, 0.45, 1.0, 0.08)
	)

	draw_arc(
		Vector2(640, 360),
		radius,
		0.0,
		TAU,
		64,
		Color(0.2, 0.7, 1.0, 0.6),
		2.0
	)


func _setup_music_bus() -> void:
	var bus: int = AudioServer.get_bus_index("Music")

	if bus == -1:
		AudioServer.add_bus()
		bus = AudioServer.bus_count - 1
		AudioServer.set_bus_name(bus, "Music")

	music.bus = &"Music"


func _setup_demo_audio() -> void:
	var music_path: String = "res://assets/music.ogg"

	if ResourceLoader.exists(music_path):
		var loaded_music: AudioStream = load(music_path) as AudioStream

		if loaded_music != null:
			music.stream = loaded_music
			music.play()
			return

	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = 44100.0
	generator.buffer_length = 0.5

	music.stream = generator
	music.play()

	demo_playback = music.get_stream_playback() as AudioStreamGeneratorPlayback


func _update_demo_audio(delta: float) -> void:
	if demo_playback == null:
		return

	demo_time += delta

	var frames: int = min(
		demo_playback.get_frames_available(),
		2048
	)

	if frames <= 0:
		return

	var buffer: PackedVector2Array = PackedVector2Array()
	buffer.resize(frames)

	for i in range(frames):
		var t: float = demo_time + float(i) / 44100.0

		# Envelope rítmico artificial para demonstrar o espectro.
		var beat: float = pow(
			max(0.0, sin(t * TAU * 2.0)),
			8.0
		)

		var bass_env: float = 0.12 + beat * 0.72

		var mid_env: float = 0.18 + pow(
			max(0.0, sin(t * TAU * 3.0 + 1.2)),
			6.0
		) * 0.42

		var high_env: float = 0.05 + pow(
			max(0.0, sin(t * TAU * 7.0 + 0.4)),
			12.0
		) * 0.22

		var sample: float = (
			sin(TAU * 80.0 * t) * bass_env * 0.35 +
			sin(TAU * 440.0 * t) * mid_env * 0.16 +
			sin(TAU * 3000.0 * t) * high_env * 0.08
		)

		buffer[i] = Vector2(sample, sample)

	demo_playback.push_buffer(buffer)


func _setup_particles() -> void:
	particles = GPUParticles2D.new()
	particles.name = "SpectrumParticles"
	particles.position = Vector2(640, 360)
	particles.amount = 180
	particles.lifetime = 1.8
	particles.explosiveness = 0.0
	particles.randomness = 0.8

	particle_material = ParticleProcessMaterial.new()
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	particle_material.emission_sphere_radius = 25.0
	particle_material.direction = Vector3(1, 0, 0)
	particle_material.spread = 180.0
	particle_material.initial_velocity_min = 30.0
	particle_material.initial_velocity_max = 130.0
	particle_material.gravity = Vector3.ZERO
	particle_material.scale_min = 0.3
	particle_material.scale_max = 1.1
	particle_material.color = Color(0.3, 0.75, 1.0, 0.8)

	particles.process_material = particle_material

	add_child(particles)
	particles.emitting = true


func _update_particles() -> void:
	if particles == null:
		return

	# Agudos -> velocidade e quantidade visual das partículas.
	particles.amount_ratio = clamp(
		0.08 + audio.treble * 0.92,
		0.0,
		1.0
	)

	particle_material.initial_velocity_min = (
		20.0 + audio.treble * 120.0
	)

	particle_material.initial_velocity_max = (
		60.0 + audio.treble * 300.0
	)

	particle_material.scale_min = (
		0.2 + audio.treble * 0.3
	)

	particle_material.scale_max = (
		0.6 + audio.treble * 1.0
	)


func _spawn_initial_enemies() -> void:
	for i in range(8):
		_spawn_enemy()


func _spawn_enemy() -> void:
	var enemy: BeatEnemy = ENEMY_SCENE.new() as BeatEnemy

	world.add_child(enemy)

	var angle: float = rng.randf_range(0.0, TAU)
	var radius: float = rng.randf_range(180.0, 360.0)

	enemy.global_position = (
		Vector2(640, 360)
		+ Vector2(cos(angle), sin(angle)) * radius
	)

	enemy.setup(
		player,
		audio,
		Vector2(640, 360),
		radius,
		angle
	)

	enemies.append(enemy)


func _exit_tree() -> void:
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
