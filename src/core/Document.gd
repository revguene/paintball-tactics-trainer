extends RefCounted

## Документ проекта .ptf
## Содержит всё состояние редактора

signal image_changed(image_path: String)
signal camera_changed(camera_position: Vector2, zoom: float)
signal layer_added(layer: Layer)
signal layer_removed(layer: Layer)
signal layer_visibility_changed(layer: Layer, visible: bool)

var workspace_name: String = ""
var author: String = ""
var created: String = ""
var modified: String = ""

var image_path: String = ""
var image_texture: Texture2D = null
var image_size: Vector2 = Vector2.ZERO

var camera: Camera = null
var layers: Array[Layer] = []

var is_dirty: bool = false

func _init():
	camera = Camera.new()
	created = Time.get_datetime_string_from_system()
	modified = created
	
	# Создаём стандартные слои
	var image_layer = Layer.new()
	image_layer.name = "Image"
	image_layer.type = "image"
	image_layer.locked = true
	layers.append(image_layer)
	
	var geometry_layer = Layer.new()
	geometry_layer.name = "Geometry"
	geometry_layer.type = "geometry"
	layers.append(geometry_layer)
	
	var players_layer = Layer.new()
	players_layer.name = "Players"
	players_layer.type = "tokens"
	layers.append(players_layer)
	
	var rays_layer = Layer.new()
	rays_layer.name = "Rays"
	rays_layer.type = "rays"
	rays_layer.opacity = 0.8
	layers.append(rays_layer)

func set_image(path: String, texture: Texture2D) -> void:
	image_path = path
	image_texture = texture
	image_size = Vector2(texture.get_width(), texture.get_height())
	is_dirty = true
	image_changed.emit(path)

func get_layer(name: String) -> Layer:
	for layer in layers:
		if layer.name == name:
			return layer
	return null

func to_dict() -> Dictionary:
	var layers_data = []
	for layer in layers:
		layers_data.append(layer.to_dict())
	
	return {
		"version": "1.0",
		"workspace": {
			"name": workspace_name,
			"author": author,
			"created": created,
			"modified": modified
		},
		"image": {
			"path": image_path,
			"width": image_size.x,
			"height": image_size.y,
			"scale": 1.0
		},
		"layers": layers_data,
		"camera": camera.to_dict()
	}

func from_dict(data: Dictionary) -> void:
	workspace_name = data.get("workspace", {}).get("name", "")
	author = data.get("workspace", {}).get("author", "")
	created = data.get("workspace", {}).get("created", "")
	modified = data.get("workspace", {}).get("modified", "")
	
	var image_data = data.get("image", {})
	image_path = image_data.get("path", "")
	image_size = Vector2(image_data.get("width", 0), image_data.get("height", 0))
	
	var layers_data = data.get("layers", [])
	layers.clear()
	for layer_data in layers_data:
		var layer = Layer.new()
		layer.from_dict(layer_data)
		layers.append(layer)
	
	camera.from_dict(data.get("camera", {}))
