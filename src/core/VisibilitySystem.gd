class_name VisibilitySystem
extends RefCounted

# === ПРОВЕРКА ВИДИМОСТИ ===
func is_visible(
	origin: Vector2,
	target: Vector2,
	bunkers: Array,
	field: Field
) -> bool:
	if not field or not field.calibrated:
		return true
	
	var direction: Vector2 = (target - origin).normalized()
	var distance: float = origin.distance_to(target)
	
	# Проверяем каждый бункер
	for bunker in bunkers:
		if bunker is Bunker:
			var hit_dist: float = bunker.intersects_ray(origin, direction, distance)
			if hit_dist < distance:
				return false
	
	return true

# === ПЕРЕСЕЧЕНИЕ ЛУЧА С УКРЫТИЕМ ===
func cast_ray(
	origin: Vector2,
	direction: Vector2,
	max_distance: float,
	bunkers: Array,
	field: Field
) -> Vector2:
	if not field or not field.calibrated:
		return origin + direction * max_distance
	
	var min_dist: float = max_distance
	var hit_point: Vector2 = origin + direction * max_distance
	
	for bunker in bunkers:
		if bunker is Bunker:
			var hit_dist: float = bunker.intersects_ray(origin, direction, max_distance)
			if hit_dist < min_dist:
				min_dist = hit_dist
				hit_point = origin + direction * hit_dist
	
	return hit_point
