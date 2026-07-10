class_name Document
extends RefCounted

var version: int = 1
var image_path: String = ""  # Относительный путь к PNG
var field: Field = null      # Калибровка
var bunkers: Array = []      # Список укрытий

func to_dictionary() -> Dictionary:
	return {
		"version": version,
		"image": image_path,
		"field": {
			"width": Field.WIDTH,
			"height": Field.HEIGHT,
			"corners": {
				"top_left": [field.top_left.x, field.top_left.y],
				"top_right": [field.top_right.x, field.top_right.y],
				"bottom_right": [field.bottom_right.x, field.bottom_right.y],
				"bottom_left": [field.bottom_left.x, field.bottom_left.y]
			}
		},
		"bunkers": _bunkers_to_array()
	}

func _bunkers_to_array() -> Array:
	var result = []
	var editor = get_tree().current_scene.get_node("FieldEditor")
	if editor:
		for child in editor.get_children():
			if child is Bunker:
				var field_pos = field.screen_to_field(child.position)
				result.append({
					"id": child.id,
					"x": field_pos.x,
					"y": field_pos.y
				})
	return result
