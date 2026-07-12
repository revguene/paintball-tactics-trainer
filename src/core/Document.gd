class_name Document
extends RefCounted

var version: int = 1
var name: String = "Untitled"
var image_path: String = ""
var image_data: String = ""  # base64

# Калибровка
var top_left: Vector2 = Vector2.ZERO
var top_right: Vector2 = Vector2.ZERO
var bottom_right: Vector2 = Vector2.ZERO
var bottom_left: Vector2 = Vector2.ZERO
var center_pixel: Vector2 = Vector2.ZERO
var calibrated: bool = false

# Данные поля
var field_width: float = 45.0
var field_height: float = 36.0

# Список укрытий (чистые данные, не Node!)
var bunkers: Array = []  # Массив словарей

func set_corners(tl: Vector2, tr: Vector2, br: Vector2, bl: Vector2) -> void:
	top_left = tl
	top_right = tr
	bottom_right = br
	bottom_left = bl
	calibrated = true

func set_center(center: Vector2) -> void:
	center_pixel = center

func add_bunker(bunker_data: Dictionary) -> void:
	bunkers.append(bunker_data)

func clear_bunkers() -> void:
	bunkers.clear()

func has_image_data() -> bool:
	return image_data != ""

func to_dictionary() -> Dictionary:
	return {
		"version": version,
		"name": name,
		"image_path": image_path,
		"image_data": image_data,
		"field": {
			"width": field_width,
			"height": field_height
		},
		"calibration": {
			"top_left": [top_left.x, top_left.y],
			"top_right": [top_right.x, top_right.y],
			"bottom_right": [bottom_right.x, bottom_right.y],
			"bottom_left": [bottom_left.x, bottom_left.y],
			"center_pixel": [center_pixel.x, center_pixel.y],
			"calibrated": calibrated
		},
		"bunkers": bunkers
	}

func from_dictionary(data: Dictionary) -> void:
	version = data.get("version", 1)
	name = data.get("name", "Untitled")
	image_path = data.get("image_path", "")
	image_data = data.get("image_data", "")
	
	var field_data = data.get("field", {})
	field_width = field_data.get("width", 45.0)
	field_height = field_data.get("height", 36.0)
	
	var calib = data.get("calibration", {})
	var tl = calib.get("top_left", [0, 0])
	var tr = calib.get("top_right", [0, 0])
	var br = calib.get("bottom_right", [0, 0])
	var bl = calib.get("bottom_left", [0, 0])
	var cp = calib.get("center_pixel", [0, 0])
	
	top_left = Vector2(tl[0], tl[1])
	top_right = Vector2(tr[0], tr[1])
	bottom_right = Vector2(br[0], br[1])
	bottom_left = Vector2(bl[0], bl[1])
	center_pixel = Vector2(cp[0], cp[1])
	calibrated = calib.get("calibrated", false)
	
	bunkers = data.get("bunkers", [])
