class_name GameManager
extends Node

# Сигналы для совместимости
signal state_changed(new_state)
signal game_over(message)

# Заглушка для setup
func setup(editor, player_editor) -> void:
	print("✅ GameManager setup вызван")
	# Ничего не делаем, все работает через GameEngine

# Заглушка для других методов
func get_state() -> int:
	return 0

func is_game_active() -> bool:
	return false

func get_human_players() -> Array:
	return []

func get_ai_players() -> Array:
	return []

func start_game() -> void:
	print("⚠️ GameManager.start_game - используйте GameEngine")

func finish_player_turn() -> void:
	print("⚠️ GameManager.finish_player_turn - используйте GameEngine")

func update(delta: float) -> void:
	pass
