extends Node2D

## Tipo de trajetória disponível.
enum CurveType {
	LINEAR,
	BEZIER
}

## Trajetória inicial.
@export var curve_type: CurveType = CurveType.LINEAR

## Velocidade do objeto na trajetória.
@export var speed: float = 0.25

## Raio visual dos pontos de controle.
@export var control_point_radius: float = 8.0

## Pontos de controle editáveis pelo Inspector.
@export var point_0: Vector2 = Vector2(150, 300)
@export var point_1: Vector2 = Vector2(300, 150)
@export var point_2: Vector2 = Vector2(550, 450)
@export var point_3: Vector2 = Vector2(700, 250)

var t: float = 0.0


func _ready():
	queue_redraw()


func _process(delta):
	# Faz o parâmetro t variar entre 0 e 1.
	t += delta * speed

	if t >= 1.0:
		t = 0.0

	queue_redraw()


## Interpolação linear entre dois pontos.
func linear_interpolation(p0: Vector2, p1: Vector2, parameter: float) -> Vector2:
	return p0.lerp(p1, parameter)


## Curva cúbica de Bézier.
func bezier_cubic(
	p0: Vector2,
	p1: Vector2,
	p2: Vector2,
	p3: Vector2,
	parameter: float
) -> Vector2:

	var u := 1.0 - parameter

	return (
		u * u * u * p0 +
		3.0 * u * u * parameter * p1 +
		3.0 * u * parameter * parameter * p2 +
		parameter * parameter * parameter * p3
	)


## Retorna a posição atual da trajetória.
func get_trajectory_position() -> Vector2:

	match curve_type:

		CurveType.LINEAR:
			return linear_interpolation(point_0, point_3, t)

		CurveType.BEZIER:
			return bezier_cubic(
				point_0,
				point_1,
				point_2,
				point_3,
				t
			)

	return point_0


func _input(event):

	# Tecla Espaço alterna entre Linear e Bézier.
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:

			if curve_type == CurveType.LINEAR:
				curve_type = CurveType.BEZIER
			else:
				curve_type = CurveType.LINEAR

			t = 0.0
			queue_redraw()


## Desenha as trajetórias e os pontos de controle.
func _draw():

	# Desenha os pontos de controle.
	draw_control_points()

	# Desenha a trajetória selecionada.
	if curve_type == CurveType.LINEAR:
		draw_linear_curve()
	else:
		draw_bezier_curve()


## Desenha os pontos de controle.
func draw_control_points():

	# Pontos utilizados pela Bézier.
	draw_circle(point_0, control_point_radius, Color.RED)
	draw_circle(point_1, control_point_radius, Color.ORANGE)
	draw_circle(point_2, control_point_radius, Color.ORANGE)
	draw_circle(point_3, control_point_radius, Color.RED)

	# Linhas auxiliares da curva de Bézier.
	draw_line(point_0, point_1, Color(0.5, 0.5, 0.5), 2.0)
	draw_line(point_1, point_2, Color(0.5, 0.5, 0.5), 2.0)
	draw_line(point_2, point_3, Color(0.5, 0.5, 0.5), 2.0)


## Desenha a trajetória linear.
func draw_linear_curve():

	draw_line(
		point_0,
		point_3,
		Color.WHITE,
		4.0
	)


## Desenha a curva cúbica de Bézier.
func draw_bezier_curve():

	var previous_point := bezier_cubic(
		point_0,
		point_1,
		point_2,
		point_3,
		0.0
	)

	# Calculamos 100 pontos intermediários.
	for i in range(1, 101):

		var parameter := float(i) / 100.0

		var current_point := bezier_cubic(
			point_0,
			point_1,
			point_2,
			point_3,
			parameter
		)

		draw_line(
			previous_point,
			current_point,
			Color.WHITE,
			4.0
		)

		previous_point = current_point
