extends Node2D

## Referência para o sistema de trajetória.
@export var trajectory: Node2D


func _process(_delta):

	if trajectory == null:
		return

	# Obtém a posição calculada pela trajetória.
	position = trajectory.get_trajectory_position()
