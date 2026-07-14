class_name Raycast
extends RefCounted

class Result:
	var hit: bool = false
	var point: Vector2 = Vector2.ZERO
	var distance: float = 0.0
	var bunker: Bunker = null
	
	func _init(p_hit: bool = false, p_point: Vector2 = Vector2.ZERO, p_distance: float = 0.0, p_bunker: Bunker = null):
		hit = p_hit
		point = p_point
		distance = p_distance
		bunker = p_bunker

static func cast(
	origin: Vector2,
	direction: Vector2,
	field: Field,
	bunkers: Array
) -> Result:
	
	# Шаг 1: Граница поля
	var boundary_hit = _intersect_field_boundary(origin, direction, field)
	if not boundary_hit.hit:
		# Если не нашли пересечение с границей (луч уходит в бесконечность)
		return Result.new(false, Vector2.ZERO, 0.0, null)
	
	# Шаг 2: Проверяем бункеры
	var nearest_hit = boundary_hit
	
	for bunker in bunkers:
		if bunker is Bunker:
			if bunker.is_mirror:
				continue
			
			var bunker_hit = _intersect_bunker(origin, direction, bunker, boundary_hit.distance)
			
			if bunker_hit.hit and bunker_hit.distance < nearest_hit.distance:
				nearest_hit = bunker_hit
	
	return nearest_hit

static func _intersect_field_boundary(origin: Vector2, direction: Vector2, field: Field) -> Result:
	if not field or not field.calibrated:
		return Result.new(false, Vector2.ZERO, 0.0, null)
	
	var max_dist = 200.0  # Большой запас
	
	# Четыре стороны поля
	var sides = [
		[Vector2(0, 0), Vector2(Field.WIDTH, 0)],                    # Верх
		[Vector2(Field.WIDTH, 0), Vector2(Field.WIDTH, Field.HEIGHT)], # Право
		[Vector2(Field.WIDTH, Field.HEIGHT), Vector2(0, Field.HEIGHT)], # Низ
		[Vector2(0, Field.HEIGHT), Vector2(0, 0)]                    # Лево
	]
	
	var min_dist = max_dist
	var hit_point = origin + direction * max_dist
	
	for side in sides:
		var a = side[0]
		var b = side[1]
		
		var hit = _segment_intersection(origin, origin + direction * max_dist, a, b)
		if hit != Vector2.ZERO:
			var dist = origin.distance_to(hit)
			if dist < min_dist:
				min_dist = dist
				hit_point = hit
	
	if min_dist < max_dist:
		return Result.new(true, hit_point, min_dist, null)
	
	# Если не нашли пересечение, проверяем в обратную сторону
	# (может быть, луч направлен в сторону от поля)
	var reversed_dir = -direction
	var rev_hit = _segment_intersection(origin, origin + reversed_dir * max_dist, 
		Vector2(0, 0), Vector2(Field.WIDTH, Field.HEIGHT))
	
	if rev_hit != Vector2.ZERO:
		var dist = origin.distance_to(rev_hit)
		if dist < max_dist:
			return Result.new(true, rev_hit, dist, null)
	
	return Result.new(false, Vector2.ZERO, 0.0, null)

static func _intersect_bunker(origin: Vector2, direction: Vector2, bunker: Bunker, max_dist: float) -> Result:
	var geometry = bunker.get_geometry()
	if not geometry:
		return Result.new(false, Vector2.ZERO, 0.0, null)
	
	var hit_dist = geometry.intersects_ray(
		origin,
		direction,
		max_dist,
		bunker.field_position,
		1.0,
		bunker.rotation
	)
	
	if hit_dist < max_dist:
		var hit_point = origin + direction * hit_dist
		return Result.new(true, hit_point, hit_dist, bunker)
	
	return Result.new(false, Vector2.ZERO, 0.0, null)

static func _segment_intersection(a1: Vector2, a2: Vector2, b1: Vector2, b2: Vector2) -> Vector2:
	var d1 = a2 - a1
	var d2 = b2 - b1
	var d = a1 - b1
	
	var cross = d1.x * d2.y - d1.y * d2.x
	
	if abs(cross) < 0.0001:
		return Vector2.ZERO
	
	var t = (d.x * d2.y - d.y * d2.x) / cross
	var u = (d.x * d1.y - d.y * d1.x) / cross
	
	if t >= 0 and t <= 1 and u >= 0 and u <= 1:
		return a1 + d1 * t
	
	return Vector2.ZERO
