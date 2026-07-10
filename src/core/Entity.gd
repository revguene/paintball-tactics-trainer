class_name Entity
extends RefCounted

## Базовый класс для всех объектов на поле

var id: String = ""
var type: String = ""
var position: Vector2 = Vector2.ZERO
var rotation: float = 0.0
var scale: Vector2 = Vector2.ONE
var properties: Dictionary = {}

func _init():
	id = str(Time.get_unix_time_from_system())

func to_dict() -> Dictionary:
	return {
		"id": id,
		"type": type,
		"position": [position.x, position.y],
		"rotation": rotation,
		"scale": [scale.x, scale.y],
		"properties": properties
	}

func from_dict(data: Dictionary) -> void:
	id = data.get("id", str(Time.get_unix_time_from_system()))
	type = data.get("type", "")
	var pos = data.get("position", [0, 0])
	position = Vector2(pos[0], pos[1])
	rotation = data.get("rotation", 0.0)
	var s = data.get("scale", [1.0, 1.0])
	scale = Vector2(s[0], s[1])
	properties = data.get("properties", {})
