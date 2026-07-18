class_name GameEngine
extends Node

var _game_manager: GameManagerCore = null
var _human_team: int = Player.Team.RED

func setup(player_editor, field_editor, field, human_team: int = Player.Team.RED) -> void:
	print("✅ GameEngine готов")
	_human_team = human_team
	print("   Игрок управляет: ", "RED" if _human_team == Player.Team.RED else "BLUE")
	
	_game_manager = GameManagerCore.new()
	add_child(_game_manager)
	_game_manager.setup(player_editor, field_editor, field, _human_team)

func start_breakout() -> void:
	if _game_manager:
		_game_manager.start_breakout()

func finish_player_turn() -> void:
	if _game_manager:
		_game_manager.finish_player_turn()

func get_state() -> int:
	if _game_manager:
		return _game_manager.get_state()
	return 0

func is_player_turn() -> bool:
	if _game_manager:
		return _game_manager.is_player_turn()
	return false

func is_ai_turn() -> bool:
	if _game_manager:
		return _game_manager.is_ai_turn()
	return false

func get_human_players() -> Array:
	return []

func get_ai_players() -> Array:
	return []
