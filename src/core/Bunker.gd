class_name Bunker
extends Node2D

@export var id: int = 0
@export var bunker_name: String = ""
@export var bunker_type: BunkerType.Type = BunkerType.Type.GIANT_BLOCK
@export var mirror_id := -1
@export var field_position := Vector2.ZERO
@export var is_mirror := false

var selected := false
var rotating := false

const HANDLE_DISTANCE := 35.0
const HANDLE_RADIUS := 12.0

const COLOR_BLUE := Color(0.4, 0.6, 0.9, 1.0)
const COLOR_RED := Color(0.85, 0.1, 0.1, 1.0)

func get_color() -> Color:
	match bunker_type:
		BunkerType.Type.GIANT_BLOCK:
			return COLOR_BLUE
		BunkerType.Type.GIANT_WING:
			return COLOR_BLUE
		BunkerType.Type.MINI_M:
			return COLOR_BLUE
		_:
			return COLOR_RED

func meter_to_px(v: float) -> float:
	return v * 20.0

func _draw():
	var info = BunkerLibrary.get_info(bunker_type)
	if info.is_empty():
		_draw_circle(0.5, COLOR_RED)
		return
	
	var color = get_color()
	
	match info.get("shape", ""):
		"rect":
			_draw_rect(info.get("width", 1.0), info.get("height", 1.0), color)
		"square":
			_draw_square(info.get("width", 1.0), color)
		"circle":
			_draw_circle(info.get("radius", 0.5), color)
		"triangle":
			_draw_triangle(info.get("size", 1.0), color)
		"wing":
			_draw_wing(info.get("width", 1.0), info.get("height", 1.0), color)
		"plus":
			_draw_plus(info.get("width", 1.0), info.get("height", 1.0), color)
		_:
			_draw_circle(0.5, color)
	
	draw_string(
		ThemeDB.fallback_font,
		Vector2(14, 5),
		str(id),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		Color(1.0, 1.0, 1.0, 0.8)
	)
	
	_draw_selection()

func _draw_selection():
	if not selected or is_mirror:
		return
	
	draw_circle(Vector2.ZERO, 16, Color(1.0, 0.8, 0.0, 0.4), false, 2.0)
	var handle = Vector2(0, -HANDLE_DISTANCE)
	draw_line(Vector2.ZERO, handle, Color(1.0, 0.8, 0.0, 0.8), 2.0)
	draw_circle(handle, HANDLE_RADIUS, Color(1.0, 0.8, 0.0, 1.0))
	draw_circle(handle, HANDLE_RADIUS, Color(1.0, 0.6, 0.0, 0.5), false, 2.0)
	
	if is_mirror:
		draw_circle(Vector2.ZERO, 16, Color(0.5, 0.5, 0.5, 0.2), false, 1.0)

func _draw_rect(w: float, h: float, color: Color) -> void:
	var r = Rect2(
		-meter_to_px(w) / 2,
		-meter_to_px(h) / 2,
		meter_to_px(w),
		meter_to_px(h)
	)
	draw_rect(r, color)
	draw_rect(r, color.darkened(0.2), false, 1.5)

func _draw_square(size: float, color: Color) -> void:
	_draw_rect(size, size, color)

func _draw_circle(radius: float, color: Color) -> void:
	var r = meter_to_px(radius)
	draw_circle(Vector2.ZERO, r, color)
	draw_circle(Vector2.ZERO, r, color.darkened(0.2), false, 1.5)

func _draw_triangle(size: float, color: Color) -> void:
	var s = meter_to_px(size) / 2
	var points = PackedVector2Array([
		Vector2(0, -s),
		Vector2(s, s),
		Vector2(-s, s)
	])
	draw_polygon(points, [color])
	var outline = PackedVector2Array(points)
	outline.append(points[0])
	draw_polyline(outline, color.darkened(0.2), 1.5)

func _draw_wing(w: float, h: float, color: Color) -> void:
	_draw_rect(w, h, color)

func _draw_plus(w: float, h: float, color: Color) -> void:
	var sw = meter_to_px(w) * 0.15
	var sh = meter_to_px(h) * 0.15
	var hw = meter_to_px(w) / 2
	var hh = meter_to_px(h) / 2
	draw_rect(Rect2(-sw, -hh, sw * 2, hh * 2), color)
	draw_rect(Rect2(-hw, -sh, hw * 2, sh * 2), color)

func select():
	if is_mirror:
		return
	selected = true
	queue_redraw()

func deselect():
	selected = false
	rotating = false
	queue_redraw()

func is_over_rotation_handle(mouse_pos: Vector2) -> bool:
	if is_mirror:
		return false
	var local = to_local(mouse_pos)
	var handle = Vector2(0, -HANDLE_DISTANCE)
	return local.distance_to(handle) <= HANDLE_RADIUS + 2

func get_pick_radius() -> float:
	var info = BunkerLibrary.get_info(bunker_type)
	if info.is_empty():
		return 30.0
	
	match info.get("shape", ""):
		"circle":
			return meter_to_px(info.get("radius", 0.5)) + 8
		"triangle":
			return meter_to_px(info.get("size", 1.0)) / 2 + 8
		"rect":
			return max(
				meter_to_px(info.get("width", 1.0)),
				meter_to_px(info.get("height", 1.0))
			) / 2 + 8
		"square":
			return meter_to_px(info.get("width", 1.0)) / 2 + 8
		"wing":
			return max(
				meter_to_px(info.get("width", 1.0)),
				meter_to_px(info.get("height", 1.0))
			) / 2 + 8
		"plus":
			return meter_to_px(info.get("width", 1.0)) / 2 + 8
		_:
			return 30.0
