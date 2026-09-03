extends CanvasLayer

@export var trajectory: Node2D
@export var label: Label


func _process(_delta):

	if trajectory == null or label == null:
		return

	if trajectory.curve_type == trajectory.CurveType.LINEAR:

		label.text = "Trajetória: LINEAR\nSPACE - Alternar trajetória"

	else:

		label.text = "Trajetória: BÉZIER CÚBICA\nSPACE - Alternar trajetória"
