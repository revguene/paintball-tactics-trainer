class_name CameraController
extends Camera2D

@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.2
@export var max_zoom: float = 5.0
@export var pan_speed: float = 1.0

var dragging := false
var last_mouse_position := Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = event.pressed
			last_mouse_position = event.position

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom(-zoom_step)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom(zoom_step)

	elif event is InputEventMouseMotion and dragging:

		var delta: Vector2 = event.position - last_mouse_position
		position -= delta * pan_speed / zoom.x
		last_mouse_position = event.position


func reset_view() -> void:
	position = Vector2.ZERO
	zoom = Vector2.ONE


func _zoom(step: float) -> void:

	var value: float = clamp(zoom.x + step, min_zoom, max_zoom)
	zoom = Vector2(value, value)
