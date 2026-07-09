extends Node2D

func _ready() -> void:
	print("Paintball Tactical Editor v0.1.0")
	print("Ready for Sprint 1 - Image Import")
	
	# Настройка камеры
	var camera = $Camera2D
	if camera:
		camera.position = get_viewport().get_visible_rect().size / 2
		camera.zoom = Vector2(1, 1)

func _input(event: InputEvent) -> void:
	# Zoom колесиком мыши (для проверки)
	if event is InputEventMouseButton:
		var camera = $Camera2D
		if camera:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				camera.zoom *= 1.1
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				camera.zoom *= 0.9
				camera.zoom = camera.zoom.clamp(Vector2(0.1, 0.1), Vector2(10, 10))
	
	# Pan (перемещение) для проверки
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		var camera = $Camera2D
		if camera:
			camera.position -= event.relative / camera.zoom
