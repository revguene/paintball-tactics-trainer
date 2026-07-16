class_name GameUI
extends Control

signal finish_turn_pressed()
signal reset_game_pressed()

func _ready() -> void:
	var btn = Button.new()
	btn.text = "✅ Завершить ход"
	btn.position = Vector2(10, 80)
	btn.size = Vector2(200, 50)
	btn.add_theme_font_size_override("font_size", 28)
	btn.pressed.connect(_on_finish_turn)
	add_child(btn)
	
	var reset = Button.new()
	reset.text = "🔄 Сброс"
	reset.position = Vector2(10, 140)
	reset.size = Vector2(200, 50)
	reset.add_theme_font_size_override("font_size", 28)
	reset.pressed.connect(_on_reset)
	add_child(reset)

func _on_finish_turn() -> void:
	finish_turn_pressed.emit()

func _on_reset() -> void:
	reset_game_pressed.emit()
