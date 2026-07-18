class_name AIController
extends RefCounted

var _field_editor = null
var _field = null
var _planner = null
var _movement = null
var _fire = null

func setup(field_editor, field) -> void:
	_field_editor = field_editor
	_field = field
	
	_planner = AIPlanner.new()
	_planner.setup(field_editor, field)
	
	_movement = AIMovement.new()
	_movement.setup(field_editor, field)
	
	_fire = AIFire.new()
	_fire.setup(field_editor, field)
	
	print("✅ AIController готов")

func do_breakout(ai_players: Array) -> void:
	print("🏃 AI разбежка")
	
	if ai_players.is_empty():
		print("⚠️ Нет AI игроков")
		return
	
	var bunkers = _get_bunkers_on_side(true)
	if bunkers.is_empty():
		bunkers = _get_all_bunkers()
	
	if bunkers.is_empty():
		print("⚠️ Нет укрытий!")
		return
	
	bunkers.shuffle()
	
	var count = mini(ai_players.size(), bunkers.size())
	for i in range(count):
		var player = ai_players[i]
		var bunker = bunkers[i]
		
		var offset = Vector2(-0.5, 0.0)
		player.position_metric = bunker.field_position + offset
		
		_update_player_visual(player)
		
		print("   AI игрок ", player.number, " → ", BunkerType.get_display_name(bunker.bunker_type))

func do_turn(ai_players: Array, human_players: Array) -> void:
	print("🤖 AI ход")
	
	if ai_players.is_empty():
		print("⚠️ Нет AI игроков")
		return
	
	for player in ai_players:
		if player.status == Player.Status.ELIMINATED:
			continue
		
		var target = _planner.select_target(player, human_players)
		
		if target:
			_fire.aim_at(player, target.position_metric)
			
			if _planner.can_see(player, target):
				_fire.shoot(player, target)
				print("   AI игрок ", player.number, " стреляет в ", target.number)
		else:
			var new_pos = _movement.find_next_position(player)
			if new_pos:
				_movement.move_to(player, new_pos)
				print("   AI игрок ", player.number, " двигается")

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
