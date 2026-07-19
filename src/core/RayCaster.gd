class_name RayCaster
extends RefCounted

const MAX_RAY_LENGTH := 100.0

static func cast(
	origin: Vector2,
	direction: Vector2,
	bunkers: Array,
	field: Field
) -> Vector2:
	
	var dir = direction.normalized()
	
	var max_point = origin + dir * MAX_RAY_LENGTH
	var closest = max_point
	var min_dist = MAX_RAY_LENGTH
	
	var boundary_hit = _intersect_field_boundary(origin, dir, field)
	if boundary_hit != Vector2.ZERO:
		min_dist = origin.distance_to(boundary_hit)
		closest = boundary_hit
	else:
		return origin + dir * MAX_RAY_LENGTH
	
	for bunker in bunkers:
		if bunker is Bunker:
			var hit_dist = bunker.intersects_ray(origin, dir, min_dist)
			if hit_dist < min_dist:
				min_dist = hit_dist
				closest = origin + dir * hit_dist
	
	return closest

static func _intersect_field_boundary(origin: Vector2, direction: Vector2, field: Field) -> Vector2:
	if not field or not field.calibrated:
		return Vector2.ZERO
	
	var max_dist = MAX_RAY_LENGTH
	var sides = [
		[Vector2(0, 0), Vector2(Field.WIDTH, 0)],
		[Vector2(Field.WIDTH, 0), Vector2(Field.WIDTH, Field.HEIGHT)],
		[Vector2(Field.WIDTH, Field.HEIGHT), Vector2(0, Field.HEIGHT)],
		[Vector2(0, Field.HEIGHT), Vector2(0, 0)]
	]
	
	var min_dist = max_dist
	var hit_point = origin + direction * max_dist
	
	for side in sides:
		var a = side[0]
		var b = side[1]
		var hit = _line_intersection(origin, origin + direction * max_dist, a, b)
		if hit != Vector2.ZERO:
			var dist = origin.distance_to(hit)
			if dist < min_dist:
				min_dist = dist
				hit_point = hit
	
	if min_dist < max_dist:
		return hit_point
	
	return Vector2.ZERO

static func _line_intersection(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> Vector2:
	var denom = (p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y)
	
	if abs(denom) < 0.0001:
		return Vector2.ZERO
	
	var ua = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)) / denom
	var ub = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x)) / denom
	
	if ua >= 0 and ua <= 1 and ub >= 0 and ub <= 1:
		var x = p1.x + ua * (p2.x - p1.x)
		var y = p1.y + ua * (p2.y - p1.y)
		return Vector2(x, y)
	
	return Vector2.ZERO
