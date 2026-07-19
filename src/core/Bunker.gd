class_name Bunker
extends Node2D

@export var id: int = 0
@export var bunker_type: BunkerType.Type = BunkerType.Type.GIANT_BLOCK
@export var mirror_id: int = -1
@export var field_position: Vector2 = Vector2.ZERO
@export var is_mirror: bool = false

var selected := false
var rotating := false
var _geometry: BunkerGeometry = null

const HANDLE_DISTANCE := 35.0
const HANDLE_RADIUS := 12.0

const COLOR_BLUE := Color(0.4, 0.6, 0.9, 1.0)
const COLOR_RED := Color(0.85, 0.1, 0.1, 1.0)
const COLOR_BANNER := Color(0.5, 0.8, 1.0, 1.0)

func get_color() -> Color:
	match bunker_type:
		BunkerType.Type.GIANT_BLOCK: return COLOR_BLUE
		BunkerType.Type.GIANT_WING: return COLOR_BLUE
		BunkerType.Type.GIANT_WING_UP: return COLOR_BLUE
		BunkerType.Type.MINI_M: return COLOR_BLUE
		BunkerType.Type.BANNER: return COLOR_BANNER
		_: return COLOR_RED

func _ready():
	z_as_relative = false
	z_index = 1000
	_geometry = BunkerGeometry.create(bunker_type)
	
	if field_position == Vector2.ZERO:
		var main = get_tree().current_scene
		if main and main.has_method("get_field"):
			var field = main.get_field()
			if field and field.calibrated:
				var info = BunkerLibrary.get_info(bunker_type)
				var half_w = info.get("width", 1.0) / 2.0
				var half_h = info.get("height", 1.0) / 2.0
				var pos = field.screen_to_field(position)
				field_position = pos - Vector2(half_w, half_h)
	
	queue_redraw()

func meter_to_px(v: float) -> float:
	return v * 20.0

func get_geometry() -> BunkerGeometry:
	if not _geometry:
		_geometry = BunkerGeometry.create(bunker_type)
	return _geometry

func intersects_ray(origin: Vector2, direction: Vector2, max_distance: float) -> float:
	if not _geometry:
		return max_distance
	
	var hit = _geometry.intersects_ray(
		origin,
		direction,
		max_distance,
		field_position,
		1.0,
		rotation
	)
	
	return hit

func _draw():
	var color = get_color()
	
	match bunker_type:
		BunkerType.Type.GIANT_BLOCK:
			_draw_rect(3.30, 2.00, color)
		BunkerType.Type.MINI_BLOCK:
			_draw_rect(1.40, 1.10, color)
		BunkerType.Type.GIANT_WING:
			_draw_rect(3.00, 2.00, color)
		BunkerType.Type.GIANT_WING_UP:
			_draw_rect(1.50, 2.00, color)
		BunkerType.Type.MINI_WING:
			_draw_rect(2.20, 1.10, color)
		BunkerType.Type.PLUS:
			_draw_plus(2.10, color)
		BunkerType.Type.MAYAN_TEMPLE:
			_draw_square(1.65, color)
		BunkerType.Type.TEMPLE:
			_draw_square(1.50, color)
		BunkerType.Type.CAN:
			_draw_circle(0.65, color)
		BunkerType.Type.PILLAR:
			_draw_circle(0.50, color)
		BunkerType.Type.CAKE:
			_draw_triangle(1.5, color)
		BunkerType.Type.CAKE_TAIL:
			_draw_rect(1.50, 1.00, color)
		BunkerType.Type.DORITO_SMALL:
			_draw_triangle(1.90, color)
		BunkerType.Type.DORITO_MEDIUM:
			_draw_triangle(2.10, color)
		BunkerType.Type.SNAKE_BEAM:
			_draw_rect(3.00, 0.50, color)
		BunkerType.Type.SNAKE_SMALL:
			_draw_rect(2.80, 0.60, color)
		BunkerType.Type.MINI_M:
			_draw_rect(1.00, 2.80, color)
		BunkerType.Type.BRICK:
			_draw_rect(1.90, 1.00, color)
		BunkerType.Type.BANNER:
			_draw_banner(color)
		_:
			_draw_circle(0.5, COLOR_RED)
	
	if selected:
		draw_circle(
			Vector2.ZERO,
			16,
			Color(1, 0.8, 0, 0.4),
			false,
			2
		)
		
		var h = Vector2(0, -HANDLE_DISTANCE)
		draw_line(
			Vector2.ZERO,
			h,
			Color.YELLOW,
			2
		)
		draw_circle(
			h,
			HANDLE_RADIUS,
			Color.YELLOW
		)
	
	if is_mirror:
		draw_circle(
			Vector2.ZERO,
			meter_to_px(1.0),
			Color(1.0, 1.0, 1.0, 0.15),
			false,
			1.0
		)

func _draw_rect(w: float, h: float, color: Color):
	var r = Rect2(
		-meter_to_px(w) / 2,
		-meter_to_px(h) / 2,
		meter_to_px(w),
		meter_to_px(h)
	)
	draw_rect(r, color)
	draw_rect(r, color.darkened(0.3), false, 2)

func _draw_square(s: float, color: Color):
	_draw_rect(s, s, color)

func _draw_circle(r: float, color: Color):
	r = meter_to_px(r)
	draw_circle(Vector2.ZERO, r, color)
	draw_circle(Vector2.ZERO, r, color.darkened(0.3), false, 2)

func _draw_triangle(size: float, color: Color):
	var s = meter_to_px(size) / 2
	var pts = PackedVector2Array([
		Vector2(0, -s),
		Vector2(s, s),
		Vector2(-s, s)
	])
	draw_polygon(pts, [color])
	
	var outline = PackedVector2Array()
	outline.append_array(pts)
	outline.append(pts[0])
	draw_polyline(outline, color.darkened(0.3), 2)

func _draw_plus(size: float, color: Color):
	var s = meter_to_px(size)
	draw_rect(Rect2(-s * 0.15, -s / 2, s * 0.3, s), color)
	draw_rect(Rect2(-s / 2, -s * 0.15, s, s * 0.3), color)

func _draw_banner(color: Color):
	var w = meter_to_px(2.5)
	var h = meter_to_px(0.2)
	var r = Rect2(-w / 2, -h / 2, w, h)
	draw_rect(r, color)
	draw_rect(r, color.darkened(0.3), false, 2)
	draw_circle(Vector2(-w / 2, 0), 3.0, Color(1.0, 1.0, 1.0, 0.5))
	draw_circle(Vector2(w / 2, 0), 3.0, Color(1.0, 1.0, 1.0, 0.5))
	draw_string(
		ThemeDB.fallback_font,
		Vector2(-20, 5),
		"B",
		HORIZONTAL_ALIGNMENT_CENTER,
		-1,
		10,
		Color(1.0, 1.0, 1.0, 0.6)
	)

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
	return local.distance_to(Vector2(0, -HANDLE_DISTANCE)) <= HANDLE_RADIUS + 2

func get_pick_radius() -> float:
	if is_mirror:
		return 0.0
	return max(40.0, meter_to_px(2.0))
