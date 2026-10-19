
extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var suzanne: MeshInstance3D = $Suzanne


func _ready() -> void:
	animation_player.play("SuzanneAction")


func _process(delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_0:
			transicao_suave("blend_shapes/Boca_Aberta", 0.0)
			transicao_suave("blend_shapes/Olhos", 0.0)
			transicao_suave("blend_shapes/Alongar", 0.0)
			print("Resetado")

		elif event.keycode == KEY_1:
			transicao_suave("blend_shapes/Boca_Aberta", 1.0)
			print("Key 1 ativada")

		elif event.keycode == KEY_2:
			transicao_suave("blend_shapes/Olhos", 1.0)
			print("Key 2 ativada")

		elif event.keycode == KEY_3:
			transicao_suave("blend_shapes/Alongar", 1.0)
			print("Key 3 ativada")


func transicao_suave(
	propriedade: String,
	valor_destino: float,
	duracao: float = 0.3
) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(suzanne, propriedade, valor_destino, duracao)
