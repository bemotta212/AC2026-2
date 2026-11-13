extends Node3D

@onready var aPlayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	aPlayer.set_blend_time("Salute", "Walking", 0.4)
	aPlayer.set_blend_time("Walking", "Salute", 0.4)
	aPlayer.set_blend_time("Salute", "Ammo", 0.4)
	aPlayer.set_blend_time("Ammo", "Salute", 0.4)
	aPlayer.set_blend_time("Walking", "Ammo", 0.4)
	aPlayer.set_blend_time("Ammo", "Walking", 0.4)

	aPlayer.play("Salute")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("animation_1"):
		aPlayer.play("Salute")

	if Input.is_action_just_pressed("animation_2"):
		aPlayer.play("Walking")

	if Input.is_action_just_pressed("animation_3"):
		aPlayer.play("Ammo")
