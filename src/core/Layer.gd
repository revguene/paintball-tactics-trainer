extends RefCounted

## Слой документа (как в Photoshop)

signal visibility_changed(visible: bool)
signal locked_changed(locked: bool)

var id: String = ""
var name: String = ""
var type: String = ""  # image, geometry, tokens, rays, movement, control, comments
var visible: bool = true
var locked: bool = false
var opacity: float = 1.0
var objects: Array = []  # Список объектов на слое

func _init():
	id = str(Time.get_unix_time_from_system())

func set_visible(value: bool) -> void:
	visible = value
	visibility_changed.emit(value)

func set_locked(value: bool) -> void:
	locked = value
	locked_changed.emit(value)

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"type": type,
		"visible": visible,
		"locked": locked,
		"opacity": opacity
	}

func from_dict(data: Dictionary) -> void:
	id = data.get("id", str(Time.get_unix_time_from_system()))
	name = data.get("name", "")
	type = data.get("type", "")
	visible = data.get("visible", true)
	locked = data.get("locked", false)
	opacity = data.get("opacity", 1.0)
