class_name BeatEnemy
extends Area2D

var target: Node2D
var audio: AudioAnalyzer
var base_speed := 70.0
var phase := 0.0
var center := Vector2.ZERO
var orbit_radius := 120.0
var life := 999.0

func setup(p_target: Node2D, p_audio: AudioAnalyzer, p_center: Vector2, p_radius: float, p_phase: float) -> void:
	target = p_target
	audio = p_audio
	center = p_center
	orbit_radius = p_radius
	phase = p_phase

func _process(delta: float) -> void:
	if audio == null:
		return

	life += delta
	var bass := audio.bass
	var mid := audio.mid
	var treble := audio.treble

	# Graves -> escala e velocidade.
	var scale_factor := 0.72 + bass * 0.9
	scale = Vector2.ONE * scale_factor

	# Médios -> trajetória orbital e mudança de direção.
	var angular_speed := 0.35 + mid * 2.5
	phase += angular_speed * delta
	var desired := center + Vector2(cos(phase), sin(phase)) * (orbit_radius + mid * 100.0)

	# Aproximação em direção ao alvo quando o médio está alto.
	var to_target := global_position.direction_to(target.global_position)
	var orbit_dir := global_position.direction_to(desired)
	var direction := orbit_dir.lerp(to_target, mid * 0.35).normalized()

	# Graves também aumentam a velocidade.
	var current_speed := base_speed + bass * 260.0
	global_position += direction * current_speed * delta

	# Agudos -> rotação.
	rotation += (0.6 + treble * 7.0) * delta

	queue_redraw()

func _draw() -> void:
	var pulse := 1.0 + sin(life * 8.0) * 0.08
	draw_circle(Vector2.ZERO, 22.0 * pulse, Color(1.0, 0.25, 0.45, 0.88))
	draw_circle(Vector2.ZERO, 11.0, Color(0.25, 0.03, 0.08))
	draw_line(Vector2(-15, -15), Vector2(15, 15), Color.WHITE, 2.0)
	draw_line(Vector2(15, -15), Vector2(-15, 15), Color.WHITE, 2.0)
