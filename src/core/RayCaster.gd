class_name RayCaster
extends RefCounted

const MAX_RAY_LENGTH := 100.0

static func cast(
	origin: Vector2,
	direction: Vector2,
	bunkers: Array,
	field: Field
) -> Vector2:
	
	var max_point = origin + direction * MAX_RAY_LENGTH
	var closest = max_point
	var min_dist = MAX_RAY_LENGTH
	
	# 1. Граница поля
	var boundary_hit = _intersect_field_boundary(origin, direction)
	if boundary_hit != Vector2.ZERO:
		min_dist = origin.distance_to(boundary_hit)
		closest = boundary_hit
	else:
		# Если не нашли пересечение, используем MAX_RAY_LENGTH
		print("   ⚠️ Нет пересечения с границей, используем MAX_RAY_LENGTH")
		return origin + direction * MAX_RAY_LENGTH
	
	# 2. Проверяем все бункеры
	for bunker in bunkers:
		if bunker is Bunker:
			var bunker_pos = bunker.field_position
			var to_bunker = bunker_pos - origin
			var proj = to_bunker.dot(direction)
			
			if proj < 0:
				continue
			
			var closest_point = origin + direction * proj
			var dist_to_bunker = closest_point.distance_to(bunker_pos)
			
			var info = BunkerLibrary.get_info(bunker.bunker_type)
			var bunker_radius = 0.5
			if not info.is_empty():
				match info.get("shape", ""):
					"circle":
						bunker_radius = info.get("radius", 0.5)
					"rect", "square", "wing", "plus", "snake":
						var w = info.get("width", 1.0)
						var h = info.get("height", 1.0)
						bunker_radius = max(w, h) / 2.0
					"triangle":
						bunker_radius = info.get("size", 1.0) / 2.0
					_:
						bunker_radius = 0.5
			
			if dist_to_bunker < bunker_radius:
				var hit_dist = proj - sqrt(bunker_radius * bunker_radius - dist_to_bunker * dist_to_bunker)
				if hit_dist > 0 and hit_dist < min_dist:
					min_dist = hit_dist
					closest = origin + direction * hit_dist
					print("   🎯 Бункер %d на %.2f м" % [bunker.id, hit_dist])
	
	return closest

# Упрощенная проверка границы поля
static func _intersect_field_boundary(origin: Vector2, direction: Vector2) -> Vector2:
	var max_dist = MAX_RAY_LENGTH
	
	# Проверяем все 4 стороны
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
		
		var hit = _line_intersection(origin, origin + direction * max_dist, a, b)
		if hit != Vector2.ZERO:
			var dist = origin.distance_to(hit)
			if dist < min_dist:
				min_dist = dist
				hit_point = hit
	
	if min_dist < max_dist:
		return hit_point
	
	return Vector2.ZERO

# Пересечение двух линий (упрощенная версия)
static func _line_intersection(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> Vector2:
	var denom = (p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y)
	
	if abs(denom) < 0.0001:
		return Vector2.ZERO  # Параллельны
	
	var ua = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)) / denom
	var ub = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x)) / denom
	
	if ua >= 0 and ua <= 1 and ub >= 0 and ub <= 1:
		var x = p1.x + ua * (p2.x - p1.x)
		var y = p1.y + ua * (p2.y - p1.y)
		return Vector2(x, y)
	
	return Vector2.ZERO
