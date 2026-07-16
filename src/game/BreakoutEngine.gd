class_name BreakoutEngine
extends RefCounted

const PLAYER_RADIUS := 0.3
const BREAKOUT_CHANCE := 0.10

var _field_editor: FieldEditor = null
var _field: Field = null

func setup(editor: FieldEditor) -> void:
	_field_editor = editor
	if editor:
		_field = editor.get_field()
	print("✅ BreakoutEngine готов")

# Выбирает укрытия для AI и сразу перемещает игроков
func execute_ai_breakout(ai_players: Array, bunkers: Array) -> Array:
	var result = {
		"players": [],
		"positioned": 0
	}
	
	if bunkers.is_empty():
		print("⚠️ Нет укрытий для разбежки!")
		return result
	
	print("🏃 Разбежка AI...")
	
	# Перемешиваем укрытия и выбираем нужное количество
	var shuffled = bunkers.duplicate()
	shuffled.shuffle()
	
	var count = mini(ai_players.size(), shuffled.size())
	
	for i in range(count):
		var player = ai_players[i]
		var bunker = shuffled[i]
		
		# Мгновенное перемещение к укрытию
		var bunker_pos = bunker.field_position
		var offset = Vector2(-1.0, 0.0)  # Перед укрытием
		player.position_metric = bunker_pos + offset
		player.current_bunker = bunker
		
		result.players.append({
			"player": player,
			"bunker": bunker,
			"position": player.position_metric
		})
		result.positioned += 1
		
		print("   AI игрок ", player.number, " → ", 
			  BunkerType.get_display_name(bunker.bunker_type),
			  " на (", player.position_metric.x, ", ", player.position_metric.y, ")")
	
	print("✅ AI расставлен: ", result.positioned, " игроков")
	return result

# Проверяет поражения на разбежке
func check_breakout_hits(human_players: Array, ai_players: Array) -> Dictionary:
	var result = {
		"human_eliminated": [],
		"ai_eliminated": [],
		"total": 0
	}
	
	print("🔫 Проверка поражений на разбежке...")
	
	# Проверяем AI → Human
	for ai in ai_players:
		if ai.status == Player.Status.ELIMINATED:
			continue
		
		for human in human_players:
			if not human.player or human.player.status == Player.Status.ELIMINATED:
				continue
			
			if _is_ray_hitting_player(ai, human.player.position_metric):
				if randf() < BREAKOUT_CHANCE:
					human.player.status = Player.Status.ELIMINATED
					human.queue_redraw()
					result.human_eliminated.append(human.player.number)
					result.total += 1
					print("💀 Игрок ", human.player.number, " поражен на разбежке!")
					break
	
	# Проверяем Human → AI
	for human in human_players:
		if not human.player or human.player.status == Player.Status.ELIMINATED:
			continue
		
		for ai in ai_players:
			if ai.status == Player.Status.ELIMINATED:
				continue
			
			if _is_ray_hitting_player(human.player, ai.position_metric):
				if randf() < BREAKOUT_CHANCE:
					ai.status = Player.Status.ELIMINATED
					result.ai_eliminated.append(ai.number)
					result.total += 1
					print("💀 AI игрок ", ai.number, " поражен на разбежке!")
					break
	
	print("   Поражено: ", result.total)
	return result

func _is_ray_hitting_player(ai_player: Player, target_pos: Vector2) -> bool:
	var origin = ai_player.position_metric
	var direction = Vector2(1, 0).rotated(ai_player.rotation)
	
	var to_target = target_pos - origin
	var proj = to_target.dot(direction)
	
	if proj < 0:
		return false
	
	var closest = origin + direction * proj
	var dist = closest.distance_to(target_pos)
	
	return dist < PLAYER_RADIUS
