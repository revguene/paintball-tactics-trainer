class_name Field
extends RefCounted

const WIDTH := 45.0
const HEIGHT := 36.0

var top_left: Vector2
var top_right: Vector2
var bottom_right: Vector2
var bottom_left: Vector2
var center_pixel: Vector2
var calibrated := false

func set_corners(tl: Vector2, tr: Vector2, br: Vector2, bl: Vector2):
	top_left = tl
	top_right = tr
	bottom_right = br
	bottom_left = bl
	calibrated = false

func set_center(center: Vector2):
	center_pixel = center
	calibrated = true
	print("✅ Калибровка завершена")
	print("   CENTER: %s" % center_pixel)

func screen_to_field(point: Vector2) -> Vector2:
	if !calibrated:
		return Vector2.ZERO
	
	var width_px = top_right.x - top_left.x
	var height_px = bottom_left.y - top_left.y
	
	if width_px <= 0 or height_px <= 0:
		return Vector2.ZERO
	
	var x = ((point.x - top_left.x) / width_px) * WIDTH
	var y = ((point.y - top_left.y) / height_px) * HEIGHT
	
	return Vector2(clamp(x, 0.0, WIDTH), clamp(y, 0.0, HEIGHT))

func field_to_screen(point: Vector2) -> Vector2:
	if !calibrated:
		return Vector2.ZERO
	
	var width_px = top_right.x - top_left.x
	var height_px = bottom_left.y - top_left.y
	
	if width_px <= 0 or height_px <= 0:
		return Vector2.ZERO
	
	var x = top_left.x + (point.x / WIDTH) * width_px
	var y = top_left.y + (point.y / HEIGHT) * height_px
	
	return Vector2(x, y)

func is_point_inside_metric(point: Vector2) -> bool:
	return point.x >= 0.0 and point.x <= WIDTH and point.y >= 0.0 and point.y <= HEIGHT

func get_center_pixel() -> Vector2:
	return center_pixel

func get_center_metric() -> Vector2:
	return Vector2(WIDTH / 2, HEIGHT / 2)

func mirror_screen_position(pos: Vector2) -> Vector2:
	if !calibrated:
		return Vector2.ZERO
	var dx = pos.x - center_pixel.x
	return Vector2(center_pixel.x - dx, pos.y)
