extends Node3D

# ============================================================
# SISTEMA DE PARTÍCULAS 3D
# ============================================================
#
# Teclas:
#
# 1 = Explosão
# 2 = Fonte
# 3 = Espiral
# 4 = Onda
# 5 = Fumaça
#
# E = troca emissor
# R = reinicia partículas
#
# Espaço = gera uma nova explosão
#
# ============================================================


# Lista de partículas existentes
var particles: Array[Particle3D] = []

# Tempo total da simulação
var simulation_time: float = 0.0

# Comportamento atual
var current_behavior: int = 1

# Emissor atual
# 0 = ponto
# 1 = esfera
# 2 = anel
var current_emitter: int = 0

# Contador para controlar nascimento
var emission_timer: float = 0.0

# Quantidade de partículas por emissão
var emission_rate: float = 0.04

# Interface
@onready var label: Label = $CanvasLayer/Label


func _ready():

	randomize()

	# Configuração inicial
	_update_interface()

	# Primeira emissão
	_create_burst()


func _process(delta):

	simulation_time += delta

	# --------------------------------------------------------
	# NASCIMENTO
	# --------------------------------------------------------

	emission_timer += delta

	if emission_timer >= emission_rate:
		emission_timer = 0.0

		_spawn_particle()

	# --------------------------------------------------------
	# EVOLUÇÃO
	# --------------------------------------------------------

	for particle in particles:

		if is_instance_valid(particle):

			particle.update_particle(
				delta,
				simulation_time
			)

	# --------------------------------------------------------
	# MORTE
	# --------------------------------------------------------

	var alive_particles: Array[Particle3D] = []

	for particle in particles:

		if not is_instance_valid(particle):
			continue

		if particle.should_die():

			particle.queue_free()

		else:

			alive_particles.append(particle)

	particles = alive_particles


# ============================================================
# NASCIMENTO
# ============================================================

func _spawn_particle():

	var particle := Particle3D.new()

	add_child(particle)

	var spawn_position := _get_emitter_position()

	var velocity := _get_initial_velocity(spawn_position)

	var color := _get_particle_color()

	var lifetime := randf_range(1.5, 3.5)

	var particle_scale := randf_range(
		0.08,
		0.25
	)

	# Alternância entre os critérios de morte
	var death_type := randi_range(0, 1)

	particle.setup(
		spawn_position,
		velocity,
		color,
		lifetime,
		particle_scale,
		current_behavior,
		death_type
	)

	particles.append(particle)


# ============================================================
# EMISSORES
# ============================================================

func _get_emitter_position() -> Vector3:

	match current_emitter:

		# ----------------------------------------------------
		# EMISSOR 1 - PONTO
		# ----------------------------------------------------
		0:
			return Vector3.ZERO

		# ----------------------------------------------------
		# EMISSOR 2 - ESFERA
		# ----------------------------------------------------
		1:
			var direction := Vector3(
				randf_range(-1.0, 1.0),
				randf_range(-1.0, 1.0),
				randf_range(-1.0, 1.0)
			).normalized()

			var radius := randf_range(
				0.0,
				1.5
			)

			return direction * radius

		# ----------------------------------------------------
		# EMISSOR 3 - ANEL
		# ----------------------------------------------------
		2:
			var angle := randf_range(
				0.0,
				TAU
			)

			var radius := 2.0

			return Vector3(
				cos(angle) * radius,
				0.0,
				sin(angle) * radius
			)

	return Vector3.ZERO


# ============================================================
# VELOCIDADE INICIAL
# ============================================================

func _get_initial_velocity(
	spawn_position: Vector3
) -> Vector3:

	match current_behavior:

		# Explosão
		1:
			return Vector3(
				randf_range(-4.0, 4.0),
				randf_range(1.0, 6.0),
				randf_range(-4.0, 4.0)
			)

		# Fonte
		2:
			return Vector3(
				randf_range(-1.5, 1.5),
				randf_range(4.0, 7.0),
				randf_range(-1.5, 1.5)
			)

		# Espiral
		3:
			return Vector3.ZERO

		# Onda
		4:
			return Vector3(
				randf_range(1.0, 3.0),
				0.0,
				randf_range(-0.5, 0.5)
			)

		# Fumaça
		5:
			return Vector3(
				randf_range(-0.3, 0.3),
				randf_range(0.5, 1.5),
				randf_range(-0.3, 0.3)
			)

	return Vector3.ZERO


# ============================================================
# CORES
# ============================================================

func _get_particle_color() -> Color:

	# ========================================================
	# EXPLOSÃO
	# ========================================================

	if current_behavior == 1:

		var explosion_colors: Array[Color] = [
			Color.WHITE,
			Color.YELLOW,
			Color.ORANGE,
			Color.RED
		]

		return explosion_colors[
			randi() % explosion_colors.size()
		]


	# ========================================================
	# FONTE
	# ========================================================

	if current_behavior == 2:

		var fountain_colors: Array[Color] = [
			Color.WHITE,
			Color.LIGHT_BLUE,
			Color.CYAN,
			Color.BLUE
		]

		return fountain_colors[
			randi() % fountain_colors.size()
		]


	# ========================================================
	# ESPIRAL
	# ========================================================

	if current_behavior == 3:

		var spiral_colors: Array[Color] = [
			Color.GREEN,
			Color.LIME_GREEN,
			Color.TURQUOISE,
			Color.BLUE
		]

		return spiral_colors[
			randi() % spiral_colors.size()
		]


	# ========================================================
	# ONDA
	# ========================================================

	if current_behavior == 4:

		var wave_colors: Array[Color] = [
			Color.PURPLE,
			Color.MAGENTA,
			Color.HOT_PINK,
			Color.PINK
		]

		return wave_colors[
			randi() % wave_colors.size()
		]


	# ========================================================
	# FUMAÇA
	# ========================================================

	if current_behavior == 5:

		var smoke_colors: Array[Color] = [
			Color(0.15, 0.15, 0.15),
			Color(0.30, 0.30, 0.30),
			Color(0.50, 0.50, 0.50),
			Color(0.70, 0.70, 0.70)
		]

		return smoke_colors[
			randi() % smoke_colors.size()
		]


	# Cor padrão
	return Color.WHITE


# ============================================================
# EXPLOSÃO INSTANTÂNEA
# ============================================================

func _create_burst():

	for i in range(100):

		_spawn_particle()


# ============================================================
# LIMPAR TODAS AS PARTÍCULAS
# ============================================================

func _clear_particles():

	for particle in particles:

		if is_instance_valid(particle):

			particle.queue_free()

	particles.clear()


# ============================================================
# TROCA DE COMPORTAMENTO
# ============================================================

func _set_behavior(new_behavior: int):

	current_behavior = new_behavior

	_clear_particles()

	_create_burst()

	_update_interface()


# ============================================================
# TROCA DE EMISSOR
# ============================================================

func _change_emitter():

	current_emitter += 1

	if current_emitter > 2:
		current_emitter = 0

	_clear_particles()

	_create_burst()

	_update_interface()


# ============================================================
# INTERFACE
# ============================================================

func _update_interface():

	var behavior_name := ""

	match current_behavior:

		1:
			behavior_name = "Explosão"

		2:
			behavior_name = "Fonte"

		3:
			behavior_name = "Espiral"

		4:
			behavior_name = "Onda"

		5:
			behavior_name = "Fumaça"

	var emitter_name := ""

	match current_emitter:

		0:
			emitter_name = "Ponto"

		1:
			emitter_name = "Esfera"

		2:
			emitter_name = "Anel"

	label.text = """
SISTEMA DE PARTÍCULAS 3D

Comportamento: %s
Emissor: %s

[1] Explosão
[2] Fonte
[3] Espiral
[4] Onda
[5] Fumaça

[E] Trocar emissor
[R] Reiniciar
[ESPAÇO] Nova explosão
""" % [
		behavior_name,
		emitter_name
	]


# ============================================================
# CONTROLES
# ============================================================

func _input(event):

	if event is InputEventKey:

		if event.pressed and not event.echo:

			match event.keycode:

				KEY_1:
					_set_behavior(1)

				KEY_2:
					_set_behavior(2)

				KEY_3:
					_set_behavior(3)

				KEY_4:
					_set_behavior(4)

				KEY_5:
					_set_behavior(5)

				KEY_E:
					_change_emitter()

				KEY_R:
					_clear_particles()
					_create_burst()

				KEY_SPACE:
					_create_burst()
