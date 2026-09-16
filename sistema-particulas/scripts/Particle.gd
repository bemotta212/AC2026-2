extends MeshInstance3D
class_name Particle3D

# ============================================================
# SISTEMA DE PARTÍCULAS 3D
# PARTÍCULA INDIVIDUAL
# ============================================================
#
# Atributos da partícula:
# - posição
# - velocidade
# - cor
# - tempo de vida
# - idade
# - escala
# - transparência
#
# Comportamentos:
# 1 = Explosão
# 2 = Fonte
# 3 = Espiral
# 4 = Onda
# 5 = Fumaça
#
# Critérios de morte:
# 0 = Tempo de vida
# 1 = Distância máxima
#
# ============================================================


# ============================================================
# MOVIMENTO
# ============================================================

var velocity: Vector3 = Vector3.ZERO
var initial_velocity: Vector3 = Vector3.ZERO


# ============================================================
# TEMPO DE VIDA
# ============================================================

var age: float = 0.0
var lifetime: float = 3.0


# ============================================================
# ESCALA
# ============================================================

var particle_scale: float = 0.2
var initial_scale: float = 0.2


# ============================================================
# COR
# ============================================================

var initial_color: Color = Color.WHITE
var current_color: Color = Color.WHITE


# ============================================================
# COMPORTAMENTO
# ============================================================

var behavior: int = 1


# ============================================================
# CRITÉRIO DE MORTE
# ============================================================

# 0 = tempo de vida
# 1 = distância máxima
var death_type: int = 0

var max_distance: float = 15.0


# ============================================================
# POSIÇÃO INICIAL
# ============================================================

var start_position: Vector3 = Vector3.ZERO


# ============================================================
# MATERIAL
# ============================================================

var material_particle: StandardMaterial3D


# ============================================================
# VARIÁVEIS ALEATÓRIAS
# ============================================================

var random_offset: Vector3 = Vector3.ZERO
var phase: float = 0.0


# ============================================================
# CONFIGURAÇÃO DA PARTÍCULA
# ============================================================

func setup(
	_start_position: Vector3,
	_start_velocity: Vector3,
	_color: Color,
	_lifetime: float,
	_scale: float,
	_behavior: int,
	_death_type: int
) -> void:

	position = _start_position
	start_position = _start_position

	velocity = _start_velocity
	initial_velocity = _start_velocity

	initial_color = _color
	current_color = _color

	lifetime = _lifetime

	particle_scale = _scale
	initial_scale = _scale

	behavior = _behavior
	death_type = _death_type


	# --------------------------------------------------------
	# Valores aleatórios
	# --------------------------------------------------------

	random_offset = Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	)

	phase = randf_range(0.0, TAU)


	# --------------------------------------------------------
	# Cria a representação visual
	# --------------------------------------------------------

	_create_mesh()


# ============================================================
# CRIAÇÃO DA MALHA
# ============================================================

func _create_mesh() -> void:

	var sphere: SphereMesh = SphereMesh.new()

	sphere.radius = 0.5
	sphere.height = 1.0

	sphere.radial_segments = 8
	sphere.rings = 4

	mesh = sphere


	# --------------------------------------------------------
	# Material
	# --------------------------------------------------------

	material_particle = StandardMaterial3D.new()

	material_particle.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	material_particle.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	material_particle.albedo_color = initial_color

	material_override = material_particle


	# --------------------------------------------------------
	# Escala inicial
	# --------------------------------------------------------

	scale = Vector3.ONE * particle_scale


# ============================================================
# ATUALIZAÇÃO DA PARTÍCULA
# ============================================================

func update_particle(delta: float, global_time: float) -> void:

	# --------------------------------------------------------
	# Aumenta a idade da partícula
	# --------------------------------------------------------

	age += delta


	# --------------------------------------------------------
	# Porcentagem da vida da partícula
	# --------------------------------------------------------

	var life_ratio: float = age / lifetime

	life_ratio = clampf(
		life_ratio,
		0.0,
		1.0
	)


	# ========================================================
	# EVOLUÇÃO
	# ========================================================

	match behavior:

		# ====================================================
		# 1 - EXPLOSÃO
		# ====================================================

		1:

			# Gravidade
			velocity.y -= 3.0 * delta

			# Movimento
			position += velocity * delta


			# ------------------------------------------------
			# Diminuição da escala
			# ------------------------------------------------

			particle_scale = lerpf(
				initial_scale,
				0.02,
				life_ratio
			)


			# ------------------------------------------------
			# Mudança de cor
			# ------------------------------------------------

			var color_progress: float = clampf(
				life_ratio,
				0.0,
				1.0
			)


			if color_progress < 0.5:

				current_color = initial_color.lerp(
					Color.ORANGE,
					color_progress * 2.0
				)

			else:

				current_color = Color.ORANGE.lerp(
					Color.RED,
					(color_progress - 0.5) * 2.0
				)


		# ====================================================
		# 2 - FONTE
		# ====================================================

		2:

			# Gravidade
			velocity.y -= 5.0 * delta

			# Movimento
			position += velocity * delta


			# ------------------------------------------------
			# Crescimento e diminuição
			# ------------------------------------------------

			if life_ratio < 0.5:

				particle_scale = lerpf(
					initial_scale,
					initial_scale * 1.5,
					life_ratio * 2.0
				)

			else:

				particle_scale = lerpf(
					initial_scale * 1.5,
					0.01,
					(life_ratio - 0.5) * 2.0
				)


			# ------------------------------------------------
			# Azul → Ciano
			# ------------------------------------------------

			current_color = initial_color.lerp(
				Color.CYAN,
				life_ratio
			)


		# ====================================================
		# 3 - ESPIRAL
		# ====================================================

		3:

			# Raio aumenta com o tempo
			var radius: float = 2.0 + life_ratio * 3.0


			# Ângulo da espiral
			var angle: float = phase + age * 5.0


			# ------------------------------------------------
			# Movimento circular
			# ------------------------------------------------

			position.x = start_position.x + cos(angle) * radius

			position.z = start_position.z + sin(angle) * radius


			# ------------------------------------------------
			# Movimento vertical
			# ------------------------------------------------

			position.y = start_position.y + age * 1.5


			# ------------------------------------------------
			# Escala pulsante
			# ------------------------------------------------

			particle_scale = initial_scale * (
				1.0 + sin(age * 8.0) * 0.4
			)


			# ------------------------------------------------
			# Verde → Azul
			# ------------------------------------------------

			current_color = Color.GREEN.lerp(
				Color.BLUE,
				life_ratio
			)


		# ====================================================
		# 4 - ONDA
		# ====================================================

		4:

			# Movimento principal
			position += velocity * delta


			# ------------------------------------------------
			# Movimento senoidal vertical
			# ------------------------------------------------

			position.y = start_position.y + \
				sin(age * 5.0 + phase) * 1.5


			# ------------------------------------------------
			# Oscilação horizontal
			# ------------------------------------------------

			position.x += sin(
				age * 3.0 + phase
			) * delta


			# ------------------------------------------------
			# Escala pulsante
			# ------------------------------------------------

			particle_scale = initial_scale * (
				1.0 + sin(age * 10.0) * 0.3
			)


			# ------------------------------------------------
			# Roxo → Rosa
			# ------------------------------------------------

			current_color = Color.PURPLE.lerp(
				Color.PINK,
				life_ratio
			)


		# ====================================================
		# 5 - FUMAÇA
		# ====================================================

		5:

			# ------------------------------------------------
			# Movimento para cima
			# ------------------------------------------------

			position.y += delta * 1.5


			# ------------------------------------------------
			# Turbulência
			# ------------------------------------------------

			position.x += sin(
				age * 2.0 + phase
			) * delta

			position.z += cos(
				age * 2.5 + phase
			) * delta


			# ------------------------------------------------
			# Fumaça aumenta de tamanho
			# ------------------------------------------------

			particle_scale = lerpf(
				initial_scale,
				initial_scale * 3.0,
				life_ratio
			)


			# ------------------------------------------------
			# Cinza escuro → Cinza claro
			# ------------------------------------------------

			current_color = Color(
				0.15,
				0.15,
				0.15
			).lerp(
				Color(
					0.7,
					0.7,
					0.7
				),
				life_ratio
			)


	# ========================================================
	# TRANSPARÊNCIA
	# ========================================================

	var alpha: float = 1.0 - life_ratio

	current_color.a = alpha


	# ========================================================
	# ATUALIZA MATERIAL
	# ========================================================

	material_particle.albedo_color = current_color


	# ========================================================
	# ATUALIZA ESCALA
	# ========================================================

	scale = Vector3.ONE * particle_scale


# ============================================================
# VERIFICA SE A PARTÍCULA DEVE MORRER
# ============================================================

func should_die() -> bool:

	# ========================================================
	# CRITÉRIO 1
	# Fim do tempo de vida
	# ========================================================

	if death_type == 0:

		return age >= lifetime


	# ========================================================
	# CRITÉRIO 2
	# Distância máxima
	# ========================================================

	if death_type == 1:

		var distance_from_start: float = position.distance_to(
			start_position
		)

		return distance_from_start >= max_distance


	# ========================================================
	# Caso padrão
	# ========================================================

	return false
