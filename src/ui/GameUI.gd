class_name GameUI
extends Control

signal finish_turn_pressed()
signal reset_game_pressed()

var status_label: Label = null

func _ready() -> void:
	status_label = Label.new()
	status_label.position = Vector2(10, 10)
	status_label.size = Vector2(400, 50)
	status_label.add_theme_font_size_override("font_size", 30)
	status_label.text = "🎮 Игра: РАЗБЕЖКА"
	status_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	add_child(status_label)
	
	var btn = Button.new()
	btn.text = "✅ Завершить ход"
	btn.position = Vector2(10, 80)
	btn.size = Vector2(250, 55)
	btn.add_theme_font_size_override("font_size", 28)
	btn.pressed.connect(_on_finish_turn)
	add_child(btn)
	
	var reset = Button.new()
	reset.text = "🔄 Сброс (на баннер)"
	reset.position = Vector2(10, 145)
	reset.size = Vector2(250, 55)
	reset.add_theme_font_size_override("font_size", 28)
	reset.pressed.connect(_on_reset)
	add_child(reset)

func _on_finish_turn() -> void:
	finish_turn_pressed.emit()

func _on_reset() -> void:
	reset_game_pressed.emit()

func set_status(text: String) -> void:
	if status_label:
		status_label.text = "🎮 " + text

func set_phase(phase: int) -> void:
	var text = ""
	match phase:
		0:
			text = "РАЗБЕЖКА"
		1:
			text = "ПРОВЕРКА РАЗБЕЖКИ"
		2:
			text = "ХОД ИГРОКА"
		3:
			text = "ХОД AI"
		4:
			text = "ИГРА ОКОНЧЕНА"
	set_status(text)
