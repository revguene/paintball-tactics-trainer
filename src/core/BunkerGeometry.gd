class_name BunkerGeometry
extends RefCounted

enum Shape {
	RECT,
	CIRCLE,
	TRIANGLE,
	POLYGON
}

var shape: Shape
var size: Vector2
var points: PackedVector2Array

static func create(type: int) -> BunkerGeometry:
	var geo = BunkerGeometry.new()
	var info = BunkerLibrary.get_info(type)
	
	if info.is_empty():
		geo.shape = Shape.CIRCLE
		geo.size = Vector2(0.5, 0.5)
		return geo
	
	var shape_name = info.get("shape", "rect")
	
	match shape_name:
		"rect":
			geo.shape = Shape.RECT
			geo.size = Vector2(info.get("width", 1.0), info.get("height", 1.0))
		
		"square":
			geo.shape = Shape.RECT
			var s = info.get("width", 1.0)
			geo.size = Vector2(s, s)
		
		"circle":
			geo.shape = Shape.CIRCLE
			var r = info.get("radius", 0.5)
			geo.size = Vector2(r, r)
		
		"triangle":
			geo.shape = Shape.TRIANGLE
			var s = info.get("size", 1.0)
			var half = s / 2.0
			geo.points = PackedVector2Array([
				Vector2(0, -half * 0.866),
				Vector2(half, half * 0.866),
				Vector2(-half, half * 0.866)
			])
		
		"wing", "plus", "snake":
			geo.shape = Shape.RECT
			geo.size = Vector2(info.get("width", 1.0), info.get("height", 1.0))
		
		_:
			geo.shape = Shape.CIRCLE
			geo.size = Vector2(0.5, 0.5)
	
	return geo

func get_local_vertices() -> PackedVector2Array:
	match shape:
		Shape.RECT:
			var half_w = size.x / 2.0
			var half_h = size.y / 2.0
			return PackedVector2Array([
				Vector2(-half_w, -half_h),
				Vector2(half_w, -half_h),
				Vector2(half_w, half_h),
				Vector2(-half_w, half_h)
			])
		
		Shape.CIRCLE:
			var pts = PackedVector2Array()
			var r = size.x
			for i in range(12):
				var angle = i * PI / 6.0
				pts.append(Vector2(cos(angle) * r, sin(angle) * r))
			return pts
		
		Shape.TRIANGLE:
			return points
		
		Shape.POLYGON:
			return points
		
		_:
			return PackedVector2Array()

func get_world_vertices(center: Vector2, scale: float = 1.0, rotation: float = 0.0) -> PackedVector2Array:
	var local = get_local_vertices()
	var result = PackedVector2Array()
	
	for p in local:
		var scaled = p * scale
		var rotated = scaled.rotated(rotation)
		result.append(center + rotated)
	
	return result

func intersects_ray(origin: Vector2, direction: Vector2, max_distance: float, center: Vector2, scale: float = 1.0, rotation: float = 0.0) -> float:
	var vertices = get_world_vertices(center, scale, rotation)
	
	match shape:
		Shape.CIRCLE:
			var radius = size.x * scale
			return _segment_intersects_circle(origin, direction, max_distance, center, radius)
		
		Shape.RECT, Shape.TRIANGLE, Shape.POLYGON:
			return _segment_intersects_polygon(origin, direction, max_distance, vertices)
		
		_:
			return max_distance

func _segment_intersects_circle(origin: Vector2, direction: Vector2, max_dist: float, center: Vector2, radius: float) -> float:
	var to_center = center - origin
	var proj = to_center.dot(direction)
	
	if proj < 0:
		return max_dist
	
	var closest = origin + direction * proj
	var dist_to_center = closest.distance_to(center)
	
	# Точное пересечение с окружностью
	if dist_to_center < radius:
		var hit_dist = proj - sqrt(radius * radius - dist_to_center * dist_to_center)
		return max(0, hit_dist)
	
	return max_dist

func _segment_intersects_polygon(origin: Vector2, direction: Vector2, max_dist: float, vertices: PackedVector2Array) -> float:
	if vertices.size() < 3:
		return max_dist
	
	var min_hit = max_dist
	
	for i in range(vertices.size()):
		var j = (i + 1) % vertices.size()
		var a = vertices[i]
		var b = vertices[j]
		
		var hit = _segment_intersects_segment(origin, direction, max_dist, a, b)
		if hit >= 0 and hit < min_hit:
			min_hit = hit
	
	return min_hit

func _segment_intersects_segment(origin: Vector2, dir: Vector2, max_dist: float, a: Vector2, b: Vector2) -> float:
	var d1 = dir
	var d2 = b - a
	var d = origin - a
	
	var cross = d1.x * d2.y - d1.y * d2.x
	
	if abs(cross) < 0.0001:
		return -1.0
	
	var t = (d.x * d2.y - d.y * d2.x) / cross
	var u = (d.x * d1.y - d.y * d1.x) / cross
	
	if t >= 0 and t <= max_dist and u >= 0 and u <= 1:
		return t
	
	return -1.0
