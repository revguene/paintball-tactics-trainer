class_name Layer
extends RefCounted

## Слой документа. Содержит коллекцию объектов одного типа.
## Аналогия: слой в Photoshop.

enum Type {
	IMAGE,      # Изображение поля (всегда один слой)
	GEOMETRY,   # Бункеры, сектора, измерения
	PLAYERS,    # Игроки (токены)
	RAYS,       # Линии стрельбы
	MOVEMENT,   # Траектории перемещения
	CONTROL,    # Зоны контроля
	COMMENTS    # Заметки, аннотации
}

var id: String
var name: String
var type: Type
var visible: bool = true
var locked: bool = false
var opacity: float = 1.0
var objects: Array = []  # Позже: Array[Entity]

func _init(p_name: String = "Новый слой", p_type: Type = Type.GEOMETRY) -> void:
	id = str(Time.get_unix_time_from_system()) + "_" + str(randi())
	name = p_name
	type = p_type

func set_visible(value: bool) -> void:
	visible = value

func set_locked(value: bool) -> void:
	locked = value

func set_opacity(value: float) -> void:
	opacity = clampf(value, 0.0, 1.0)

func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"type": type,
		"visible": visible,
		"locked": locked,
		"opacity": opacity,
		"objects": objects  # Позже: objects.map(func(o): return o.to_dictionary())
	}

func from_dictionary(data: Dictionary) -> void:
	id = data.get("id", str(Time.get_unix_time_from_system()) + "_" + str(randi()))
	name = data.get("name", "Новый слой")
	type = data.get("type", Type.GEOMETRY)
	visible = data.get("visible", true)
	locked = data.get("locked", false)
	opacity = data.get("opacity", 1.0)
	# objects будет заполняться позже, после создания Entity
