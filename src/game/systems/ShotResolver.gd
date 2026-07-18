class_name ShotResolver
extends RefCounted

var _field_editor = null
var _field = null
var _visibility = null

func setup(field_editor, field) -> void:
	_field_editor = field_editor
	_field = field
	_visibility = VisibilitySystem.new()
	print("✅ ShotResolver готов")

func resolve_all_shots() -> void:
	print("🔫 Проверка поражений...")
	
	var players = _get_all_players()
	var eliminated = 0
	
	for shooter in players:
		if shooter.status == Player.Status.ELIMINATED:
			continue
		
		if not shooter.fire_enabled:
			continue
		
		for target in players:
			if target == shooter:
				continue
			
			if target.status == Player.Status.ELIMINATED:
				continue
			
			if _can_hit(shooter, target):
				target.status = Player.Status.ELIMINATED
				eliminated += 1
				print("💀 Игрок ", target.number, " поражен!")
				_update_player_visual(target)
	
	print("   Поражено: ", eliminated)

func _can_hit(shooter: Player, target: Player) -> bool:
	# Проверяем направление луча
	var dir := Vector2(1, 0).rotated(shooter.rotation)
	var to_target := target.position_metric - shooter.position_metric
	
	# Проверяем угол между направлением луча и целью
	var angle_diff := dir.angle_to(to_target)
	if abs(angle_diff) > 0.3:  # ~17 градусов
		return false
	
	# Проверяем расстояние
	var dist := shooter.position_metric.distance_to(target.position_metric)
	if dist > 50.0:
		return false
	
	# Проверяем, есть ли укрытие
	var bunkers = _get_bunkers()
	return _visibility.is_visible(
		shooter.position_metric,
		target.position_metric,
		bunkers,
		_field
	)

func _get_all_players() -> Array:
	var result = []
	if not _field_editor:
		return result
	
	var main = _field_editor.get_tree().current_scene
	if main:
		var player_editor = main.get_node_or_null("PlayerEditor")
		if player_editor:
			for visual in player_editor.players:
				if visual.player:
					result.append(visual.player)
	
	return result

func _get_bunkers() -> Array:
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
					visual.queue_redraw()
					break
