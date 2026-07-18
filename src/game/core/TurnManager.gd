class_name TurnManager
extends RefCounted

signal turn_finished()
signal ai_turn_finished()

var _player_editor = null
var _field_editor = null
var _field = null

func setup(player_editor, field_editor, field) -> void:
	_player_editor = player_editor
	_field_editor = field_editor
	_field = field
	print("✅ TurnManager готов")

func start_breakout() -> void:
	print("🏃 Разбежка")
	# AI занимает укрытия
	var ai_controller = AIController.new()
	ai_controller.setup(_field_editor, _field)
	ai_controller.do_breakout(_get_ai_players())

func start_ai_turn() -> void:
	print("🤖 AI ход")
	var ai_controller = AIController.new()
	ai_controller.setup(_field_editor, _field)
	ai_controller.do_turn(_get_ai_players(), _get_human_players())
	
	# Сигнал о завершении AI хода
	ai_turn_finished.emit()

func _get_human_players() -> Array:
	var result = []
	if not _player_editor:
		return result
	
	for visual in _player_editor.players:
		if visual.player and visual.player.team == Player.Team.RED:
			result.append(visual.player)
	return result

func _get_ai_players() -> Array:
	var result = []
	if not _player_editor:
		return result
	
	for visual in _player_editor.players:
		if visual.player and visual.player.team == Player.Team.BLUE:
			result.append(visual.player)
	return result
