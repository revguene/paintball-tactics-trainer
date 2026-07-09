extends RefCounted

## Камера для работы с видом на поле

signal position_changed(new_position: Vector2)
signal zoom_changed(new_zoom: float)

var position: Vector2 = Vector2.ZERO
var zoom: float = 1.0
var min_zoom: float = 0.1
var max_zoom: float = 10.0
var bounds: Rect2 = Rect2(0, 0, 1920, 1080)

func set_position(new_position: Vector2) -> void:
	position = new_position
	position_changed.emit(position)

func set_zoom(new_zoom: float) -> void:
	zoom = clamp(new_zoom, min_zoom, max_zoom)
	zoom_changed.emit(zoom)

func zoom_in(factor: float = 1.1) -> void:
	set_zoom(zoom * factor)

func zoom_out(factor: float = 1.1) -> void:
	set_zoom(zoom / factor)

func pan(delta: Vector2) -> void:
	set_position(position + delta)

func to_dict() -> Dictionary:
	return {
		"position": [position.x, position.y],
		"zoom": zoom,
		"bounds": [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y]
	}

func from_dict(data: Dictionary) -> void:
	var pos = data.get("position", [0, 0])
	position = Vector2(pos[0], pos[1])
	zoom = data.get("zoom", 1.0)
	
	var b = data.get("bounds", [0, 0, 1920, 1080])
	bounds = Rect2(b[0], b[1], b[2], b[3])
