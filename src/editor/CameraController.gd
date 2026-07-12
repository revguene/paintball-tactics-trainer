class_name CameraController
extends Camera2D

@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.1
@export var max_zoom: float = 10.0
@export var pan_speed: float = 1.0

var dragging := false
var is_panning := false
var last_mouse_position := Vector2.ZERO
var drag_start_pos := Vector2.ZERO
var drag_start_camera_pos := Vector2.ZERO

var field_bounds: Rect2 = Rect2(0, 0, 1920, 1080)

func _ready() -> void:
	_update_bounds()

func _update_bounds() -> void:
	var main = get_tree().current_scene
	if main:
		var field_image = main.get_node_or_null("Field/FieldImage")
		if field_image and field_image.texture:
			var size = Vector2(field_image.texture.get_width(), field_image.texture.get_height())
			field_bounds = Rect2(-size / 2, size)
	else:
		field_bounds = Rect2(-960, -540, 1920, 1080)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom(-zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom(zoom_step)
		
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				dragging = true
				is_panning = true
				last_mouse_position = event.position
				drag_start_pos = event.position
				drag_start_camera_pos = position
				Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			else:
				dragging = false
				is_panning = false
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and Input.is_key_pressed(KEY_SPACE):
				is_panning = true
				dragging = true
				last_mouse_position = event.position
				drag_start_pos = event.position
				drag_start_camera_pos = position
				Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			else:
				if is_panning:
					is_panning = false
					dragging = false
					Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	if event is InputEventMouseMotion:
		if dragging and is_panning:
			var delta: Vector2 = event.position - last_mouse_position
			position -= delta * pan_speed / zoom.x
			last_mouse_position = event.position
			_clamp_position()

func _zoom(step: float) -> void:
	var old_zoom = zoom.x
	var new_zoom = clamp(zoom.x + step, min_zoom, max_zoom)
	
	if new_zoom == old_zoom:
		return
	
	# Правильный зум относительно курсора
	var mouse_pos = get_global_mouse_position()
	
	# Вычисляем, где находится курсор относительно центра камеры
	var offset = mouse_pos - position
	
	# Применяем новый зум
	var zoom_ratio = old_zoom / new_zoom
	zoom = Vector2(new_zoom, new_zoom)
	
	# Корректируем позицию камеры, чтобы курсор остался на месте
	position = mouse_pos - offset * (old_zoom / new_zoom)
	
	_clamp_position()

func _clamp_position() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var half_view = viewport_size / 2
	
	var visible_width = viewport_size.x / zoom.x
	var visible_height = viewport_size.y / zoom.y
	
	var min_x = field_bounds.position.x + visible_width / 2
	var max_x = field_bounds.end.x - visible_width / 2
	var min_y = field_bounds.position.y + visible_height / 2
	var max_y = field_bounds.end.y - visible_height / 2
	
	if max_x < min_x:
		position.x = field_bounds.get_center().x
	else:
		position.x = clamp(position.x, min_x, max_x)
	
	if max_y < min_y:
		position.y = field_bounds.get_center().y
	else:
		position.y = clamp(position.y, min_y, max_y)

func reset_view() -> void:
	position = Vector2.ZERO
	zoom = Vector2.ONE
	_clamp_position()
