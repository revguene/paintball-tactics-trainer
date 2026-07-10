class_name Document
extends RefCounted

const CURRENT_VERSION := 1

var uuid: String
var name: String
var version: int

# Относительный путь к изображению поля
var image_path: String

# Список слоёв (теперь с типом!)
var layers: Array[Layer]

# Состояние камеры
var camera_position: Vector2
var camera_zoom: float

# Метаданные
var metadata := {
	"author": "",
	"created": "",
	"modified": "",
	"description": ""
}

# Есть ли несохранённые изменения
var modified: bool = false


func _init() -> void:
	uuid = _generate_uuid()
	name = "Untitled"
	version = CURRENT_VERSION
	image_path = ""
	layers = []

	camera_position = Vector2.ZERO
	camera_zoom = 1.0


func add_layer(layer: Layer) -> void:
	if layer == null:
		return

	layers.append(layer)
	mark_modified()


func remove_layer(layer: Layer) -> bool:
	if not layers.has(layer):
		return false

	layers.erase(layer)
	mark_modified()
	return true


func get_layer_by_name(layer_name: String) -> Layer:
	for layer in layers:
		if layer.name == layer_name:
			return layer

	return null


func mark_modified() -> void:
	modified = true


func clear_modified() -> void:
	modified = false


func to_dictionary() -> Dictionary:
	var layer_data := []

	for layer in layers:
		layer_data.append(layer.to_dictionary())

	return {
		"version": version,
		"uuid": uuid,
		"name": name,
		"image_path": image_path,
		"camera": {
			"position": {
				"x": camera_position.x,
				"y": camera_position.y
			},
			"zoom": camera_zoom
		},
		"layers": layer_data,
		"metadata": metadata
	}


func from_dictionary(data: Dictionary) -> void:
	version = data.get("version", CURRENT_VERSION)
	uuid = data.get("uuid", _generate_uuid())
	name = data.get("name", "Untitled")
	image_path = data.get("image_path", "")

	var camera_data = data.get("camera", {})
	
	# Правильно загружаем Vector2 из словаря
	var pos_data = camera_data.get("position", {"x": 0, "y": 0})
	if pos_data is Vector2:
		camera_position = pos_data
	else:
		camera_position = Vector2(
			pos_data.get("x", 0.0),
			pos_data.get("y", 0.0)
		)
	
	camera_zoom = camera_data.get("zoom", 1.0)

	metadata = data.get("metadata", metadata)

	# Загружаем слои
	layers = []
	var layers_data = data.get("layers", [])
	for layer_data in layers_data:
		var layer = Layer.new()
		layer.from_dictionary(layer_data)
		layers.append(layer)

	modified = false


func _generate_uuid() -> String:
	return str(Time.get_unix_time_from_system()) + "_" + str(randi())


# === Serialization ===

func save(path: String) -> Error:
	return ProjectSerializer.save_document(self, path)


static func load(path: String) -> Document:
	return ProjectSerializer.load_document(path)
