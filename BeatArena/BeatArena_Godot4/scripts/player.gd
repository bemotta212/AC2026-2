extends CharacterBody2D

@export var speed := 320.0
var arena_rect := Rect2(35, 35, 1210, 650)

func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_vector * speed
	move_and_slide()

	global_position.x = clamp(global_position.x, arena_rect.position.x, arena_rect.end.x)
	global_position.y = clamp(global_position.y, arena_rect.position.y, arena_rect.end.y)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 18.0, Color(0.25, 0.85, 1.0))
	draw_circle(Vector2.ZERO, 9.0, Color(0.05, 0.15, 0.25))
	draw_line(Vector2(0, -12), Vector2(0, 12), Color.WHITE, 2.0)
