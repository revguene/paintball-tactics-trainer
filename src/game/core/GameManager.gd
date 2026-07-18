class_name GameManagerCore
extends Node

enum GameState {
	WAIT_START,
	BREAKOUT,
	PLAYER_TURN,
	AI_TURN,
	GAME_OVER
}

var state: GameState = GameState.WAIT_START
var turn_number: int = 0
var _human_team: int = Player.Team.RED

signal state_changed(new_state: GameState)
signal game_over(winner: String)

var _turn_manager = null
var _ai_controller = null
var _shot_resolver = null
var _win_condition = null
var _player_editor = null

func setup(player_editor, field_editor, field, human_team: int = Player.Team.RED) -> void:
	print("🎮 GameManager setup")
	_player_editor = player_editor
	_human_team = human_team
	print("   Игрок управляет: ", "RED" if _human_team == Player.Team.RED else "BLUE")
	
	_turn_manager = TurnManager.new()
	_turn_manager.setup(player_editor, field_editor, field)
	
	_ai_controller = AIController.new()
	_ai_controller.setup(field_editor, field)
	
	_shot_resolver = ShotResolver.new()
	_shot_resolver.setup(field_editor, field)
	
	_win_condition = WinCondition.new()
	_win_condition.setup(player_editor)
	
	_turn_manager.turn_finished.connect(_on_turn_finished)
	_turn_manager.ai_turn_finished.connect(_on_ai_turn_finished)
	
	state = GameState.BREAKOUT
	state_changed.emit(state)
	print("🎮 Игра в режиме BREAKOUT")

func start_breakout() -> void:
	if state != GameState.BREAKOUT:
		return
	
	print("🏃 Разбежка...")
	_turn_manager.start_breakout()
	
	state = GameState.PLAYER_TURN
	state_changed.emit(state)
	
	if _player_editor and _player_editor.has_method("unlock_movement"):
		_player_editor.unlock_movement()
	
	print("🎯 Ход игрока")

func finish_player_turn() -> void:
	if state != GameState.PLAYER_TURN:
		return
	
	print("👤 Игрок завершил ход")
	
	if _player_editor and _player_editor.has_method("lock_movement"):
		_player_editor.lock_movement()
	
	_shot_resolver.resolve_all_shots()
	
	if _win_condition.check_win():
		state = GameState.GAME_OVER
		state_changed.emit(state)
		game_over.emit(_win_condition.get_winner())
		return
	
	state = GameState.AI_TURN
	state_changed.emit(state)
	_turn_manager.start_ai_turn()

func _on_turn_finished() -> void:
	finish_player_turn()

func _on_ai_turn_finished() -> void:
	_shot_resolver.resolve_all_shots()
	
	if _win_condition.check_win():
		state = GameState.GAME_OVER
		state_changed.emit(state)
		game_over.emit(_win_condition.get_winner())
		return
	
	state = GameState.PLAYER_TURN
	state_changed.emit(state)
	
	if _player_editor and _player_editor.has_method("unlock_movement"):
		_player_editor.unlock_movement()
	
	print("🎯 Ход игрока")

func get_state() -> GameState:
	return state

func is_player_turn() -> bool:
	return state == GameState.PLAYER_TURN

func is_ai_turn() -> bool:
	return state == GameState.AI_TURN

func get_human_team() -> int:
	return _human_team
