class_name AIPlanner
extends RefCounted

var _field_editor = null
var _field = null
var _visibility: VisibilitySystem = null

func setup(field_editor, field) -> void:
	_field_editor = field_editor
	_field = field
	_visibility = VisibilitySystem.new()
	print("✅ AIPlanner готов")

func select_target(player: Player, enemies: Array) -> Player:
	if enemies.is_empty():
		return null
	
	var nearest = null
	var nearest_dist := 1000.0
	
	for enemy in enemies:
		if enemy.status == Player.Status.ELIMINATED:
			continue
		
		var dist: float = player.position_metric.distance_to(enemy.position_metric)
		
		if can_see(player, enemy):
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = enemy
	
	return nearest

func can_see(player: Player, target: Player) -> bool:
	if not _field or not _field.calibrated:
		return false
	
	var bunkers: Array = _get_bunkers()
	var origin: Vector2 = player.position_metric
	var target_pos: Vector2 = target.position_metric
	
	return _visibility.is_visible(origin, target_pos, bunkers, _field)

func _get_bunkers() -> Array:
	var result: Array = []
	if not _field_editor:
		return result
	
	for child in _field_editor.get_children():
		if child is Bunker:
			result.append(child)
	
	return result
