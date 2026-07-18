class_name AIMovement
extends RefCounted

var _field_editor = null
var _field = null

func setup(field_editor, field) -> void:
	_field_editor = field_editor
	_field = field
	print("✅ AIMovement готов")

func find_next_position(player: Player) -> Vector2:
	# Просто ищем ближайшее укрытие
	var bunkers = _get_bunkers_on_side(true)
	if bunkers.is_empty():
		bunkers = _get_all_bunkers()
	
	if bunkers.is_empty():
		return Vector2.ZERO
	
	var nearest = null
	var nearest_dist = 1000.0
	
	for bunker in bunkers:
		var dist = player.position_metric.distance_to(bunker.field_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = bunker
	
	if nearest:
		return nearest.field_position + Vector2(-0.5, 0.0)
	
	return Vector2.ZERO

func move_to(player: Player, target_pos: Vector2) -> void:
	player.position_metric = target_pos
	_update_player_visual(player)

func _get_bunkers_on_side(right: bool) -> Array:
	var result = []
	if not _field_editor:
		return result
	
	for child in _field_editor.get_children():
		if child is Bunker:
			if right and child.field_position.x > Field.WIDTH * 0.5:
				result.append(child)
			elif not right and child.field_position.x < Field.WIDTH * 0.5:
				result.append(child)
	
	return result

func _get_all_bunkers() -> Array:
	var result = []
	if not _field_editor:
		return result
	
	for child in _field_editor.get_children():
		if child is Bunker:
			result.append(child)
	
	return result

func _update_player_visual(player: Player) -> void:
	if not _field_editor:
		return
	
	var main = _field_editor.get_tree().current_scene
	if main:
		var player_editor = main.get_node_or_null("PlayerEditor")
		if player_editor:
			for visual in player_editor.players:
				if visual.player == player:
					visual.update_position()
					visual.queue_redraw()
					break
