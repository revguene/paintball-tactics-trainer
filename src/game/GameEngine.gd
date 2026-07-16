class_name GameEngine
extends Node

enum GamePhase {
	BREAKOUT,
	BREAKOUT_CHECK,
	PLAYER_TURN,
	AI_TURN,
	GAME_OVER
}

var phase: GamePhase = GamePhase.BREAKOUT
var _player_editor: PlayerEditor = null
var _field_editor: FieldEditor = null
var _field: Field = null

var _human_players: Array = []
var _ai_players: Array = []

var _breakout_paths: Dictionary = {}
var _rng := RandomNumberGenerator.new()

const BREAKOUT_PROBABILITY := 0.10

signal phase_changed(new_phase: GamePhase)
signal player_eliminated(visual: PlayerVisual)
signal breakout_complete()

func setup(player_editor: PlayerEditor, field_editor: FieldEditor, field: Field) -> void:
	_player_editor = player_editor
	_field_editor = field_editor
	_field = field
	_rng.randomize()
	print("✅ GameEngine готов")

func start_breakout() -> void:
	if phase != GamePhase.BREAKOUT:
		print("⚠️ Разбежка уже начата!")
		return
	
	print("🏃 Фиксация разбежки...")
	phase = GamePhase.BREAKOUT_CHECK
	phase_changed.emit(phase)
	
	_human_players = []
	_ai_players = []
	
	for visual in _player_editor.players:
		if visual.player:
			if visual.player.team == Player.Team.RED:
				_human_players.append(visual)
			else:
				_ai_players.append(visual)
	
	_ai_breakout_setup()
	_fix_breakout_paths()
	_check_breakout_collisions()
	
	phase = GamePhase.PLAYER_TURN
	phase_changed.emit(phase)
	breakout_complete.emit()
	print("🎯 Разбежка завершена! Начинается пошаговая игра")

func _ai_breakout_setup() -> void:
	print("🤖 AI занимает укрытия на разбежке...")
	
	var right_bunkers: Array[Bunker] = []
	for node in _field_editor.get_children():
		if node is Bunker:
			if node.field_position.x > Field.WIDTH * 0.5:
				right_bunkers.append(node)
	
	if right_bunkers.is_empty():
		print("⚠️ Нет бункеров на правой стороне! Использую все")
		right_bunkers = _get_all_bunkers()
	
	if right_bunkers.is_empty():
		print("⚠️ Вообще нет бункеров!")
		return
	
	right_bunkers.shuffle()
	var count = mini(_ai_players.size(), right_bunkers.size())
	
	for i in range(count):
		var visual = _ai_players[i]
		var bunker = right_bunkers[i]
		
		if not visual or not visual.player:
			continue
		
		if visual.player.status == Player.Status.ELIMINATED:
			continue
		
		var offset = Vector2(-0.5, 0.0)
		visual.player.position_metric = bunker.field_position + offset
		
		visual.update_position()
		visual.queue_redraw()
		
		print("   AI игрок %d → %s на (%.2f, %.2f)" % [
			visual.player.number,
			BunkerType.get_display_name(bunker.bunker_type),
			visual.player.position_metric.x,
			visual.player.position_metric.y
		])

func _get_all_bunkers() -> Array[Bunker]:
	var result: Array[Bunker] = []
	for node in _field_editor.get_children():
		if node is Bunker:
			result.append(node)
	return result

func _fix_breakout_paths() -> void:
	print("📝 Фиксация траекторий игроков...")
	
	for visual in _human_players:
		if visual.player.status == Player.Status.ELIMINATED:
			continue
		
		var start_x = 1.0 if visual.player.team == Player.Team.RED else 44.0
		var start_pos = Vector2(start_x, visual.player.position_metric.y)
		
		_breakout_paths[visual] = {
			"start": start_pos,
			"end": visual.player.position_metric,
			"target": visual.position
		}
		
		print("   Игрок %d: (%.1f, %.1f) → (%.1f, %.1f)" % [
			visual.player.number,
			start_pos.x, start_pos.y,
			visual.player.position_metric.x, visual.player.position_metric.y
		])
	
	for visual in _ai_players:
		if visual.player.status == Player.Status.ELIMINATED:
			continue
		
		var start_x = 1.0 if visual.player.team == Player.Team.RED else 44.0
		var start_pos = Vector2(start_x, visual.player.position_metric.y)
		
		_breakout_paths[visual] = {
			"start": start_pos,
			"end": visual.player.position_metric,
			"target": visual.position
		}

func _check_breakout_collisions() -> void:
	print("🔫 Проверка поражений на разбежке...")
	
	var all_players = _human_players + _ai_players
	var eliminated = []
	
	for visual in all_players:
		if visual.player.status == Player.Status.ELIMINATED:
			continue
		
		var is_human = visual.player.team == Player.Team.RED
		var enemies = _ai_players if is_human else _human_players
		var player_radius = 12.0
		
		for enemy in enemies:
			if enemy.player.status == Player.Status.ELIMINATED:
				continue
			
			var origin = enemy.position
			var direction = Vector2(1, 0).rotated(enemy.player.rotation)
			var ray_end = origin + direction * 2000.0
			
			var hit = _segment_intersects_circle(origin, ray_end, visual.position, player_radius)
			
			if hit:
				if randf() < BREAKOUT_PROBABILITY:
					visual.player.status = Player.Status.ELIMINATED
					visual.queue_redraw()
					eliminated.append(visual)
					player_eliminated.emit(visual)
					print("💀 Игрок %d поражен на разбежке!" % visual.player.number)
					break
	
	var human_alive = 0
	var ai_alive = 0
	
	for visual in _human_players:
		if visual.player.status == Player.Status.ACTIVE:
			human_alive += 1
	
	for visual in _ai_players:
		if visual.player.status == Player.Status.ACTIVE:
			ai_alive += 1
	
	print("   Human alive: %d" % human_alive)
	print("   AI alive: %d" % ai_alive)

func _segment_intersects_circle(segment_start: Vector2, segment_end: Vector2, circle_center: Vector2, circle_radius: float) -> bool:
	var d = segment_end - segment_start
	var f = segment_start - circle_center
	
	var a = d.dot(d)
	var b = 2 * f.dot(d)
	var c = f.dot(f) - circle_radius * circle_radius
	
	var discriminant = b * b - 4 * a * c
	
	if discriminant < 0:
		return false
	
	discriminant = sqrt(discriminant)
	var t1 = (-b - discriminant) / (2 * a)
	var t2 = (-b + discriminant) / (2 * a)
	
	if t1 >= 0 and t1 <= 1:
		return true
	if t2 >= 0 and t2 <= 1:
		return true
	
	return false

func get_phase() -> GamePhase:
	return phase

func is_breakout() -> bool:
	return phase == GamePhase.BREAKOUT

func is_player_turn() -> bool:
	return phase == GamePhase.PLAYER_TURN

func finish_player_turn() -> void:
	if phase != GamePhase.PLAYER_TURN:
		print("⚠️ Сейчас не ход игрока!")
		return
	
	print("👤 Игрок завершил ход!")
	
	phase = GamePhase.AI_TURN
	phase_changed.emit(phase)
	print("🤖 Фаза: AI_TURN - Ход AI...")
	
	_ai_move_players()
	_check_post_move_eliminations()
	
	phase = GamePhase.PLAYER_TURN
	phase_changed.emit(phase)
	print("🎯 Фаза: PLAYER_TURN - Ход игрока!")

func _ai_move_players() -> void:
	print("🤖 AI перемещает игроков...")
	
	var right_bunkers: Array[Bunker] = []
	for node in _field_editor.get_children():
		if node is Bunker:
			if node.field_position.x > Field.WIDTH * 0.5:
				right_bunkers.append(node)
	
	if right_bunkers.is_empty():
		print("⚠️ Нет бункеров на правой стороне!")
		return
	
	right_bunkers.shuffle()
	
	var count = mini(_ai_players.size(), right_bunkers.size())
	
	for i in range(count):
		var visual = _ai_players[i]
		var bunker = right_bunkers[i]
		
		if not visual or not visual.player:
			continue
		
		if visual.player.status == Player.Status.ELIMINATED:
			continue
		
		var offset = Vector2(-0.5, 0.0)
		visual.player.position_metric = bunker.field_position + offset
		
		visual.update_position()
		visual.queue_redraw()
		
		print("   AI игрок %d → %s на (%.2f, %.2f)" % [
			visual.player.number,
			BunkerType.get_display_name(bunker.bunker_type),
			visual.player.position_metric.x,
			visual.player.position_metric.y
		])

func _check_post_move_eliminations() -> void:
	print("🔫 Проверка поражений после хода...")
	
	var eliminated = 0
	
	for ai in _ai_players:
		if not ai.player or ai.player.status == Player.Status.ELIMINATED:
			continue
		
		for human in _human_players:
			if not human.player or human.player.status == Player.Status.ELIMINATED:
				continue
			
			if _is_ray_hitting_player(ai.player, human.player.position_metric):
				human.player.status = Player.Status.ELIMINATED
				human.queue_redraw()
				eliminated += 1
				player_eliminated.emit(human)
				print("💀 Игрок %d поражен!" % human.player.number)
				break
	
	for human in _human_players:
		if not human.player or human.player.status == Player.Status.ELIMINATED:
			continue
		
		for ai in _ai_players:
			if not ai.player or ai.player.status == Player.Status.ELIMINATED:
				continue
			
			if _is_ray_hitting_player(human.player, ai.player.position_metric):
				ai.player.status = Player.Status.ELIMINATED
				ai.queue_redraw()
				eliminated += 1
				player_eliminated.emit(ai)
				print("💀 AI игрок %d поражен!" % ai.player.number)
				break
	
	print("   Поражено: %d" % eliminated)
	_check_game_over()

func _is_ray_hitting_player(shooter: Player, target_pos: Vector2) -> bool:
	var origin = shooter.position_metric
	var direction = Vector2(1, 0).rotated(shooter.rotation)
	
	var to_target = target_pos - origin
	var proj = to_target.dot(direction)
	
	if proj < 0:
		return false
	
	var closest = origin + direction * proj
	var dist = closest.distance_to(target_pos)
	
	return dist < 0.3

func _check_game_over() -> void:
	var humans_alive = 0
	for visual in _human_players:
		if visual.player and visual.player.status == Player.Status.ACTIVE:
			humans_alive += 1
	
	var ais_alive = 0
	for visual in _ai_players:
		if visual.player and visual.player.status == Player.Status.ACTIVE:
			ais_alive += 1
	
	if humans_alive == 0:
		phase = GamePhase.GAME_OVER
		phase_changed.emit(phase)
		print("🏆 AI победил!")
	elif ais_alive == 0:
		phase = GamePhase.GAME_OVER
		phase_changed.emit(phase)
		print("🏆 Игрок победил!")

func get_human_players() -> Array:
	return _human_players

func get_ai_players() -> Array:
	return _ai_players

func get_breakout_paths() -> Dictionary:
	return _breakout_paths
