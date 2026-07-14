class_name PlayerTypeMenu
extends PopupMenu

signal player_selected(team: int)

func _ready() -> void:
	# Увеличиваем шрифт
	add_theme_font_size_override("font_size", 28)
	
	add_item("🔴 Red Player", 0)
	add_item("🔵 Blue Player", 1)
	
	id_pressed.connect(_on_item_selected)

func _on_item_selected(id: int) -> void:
	player_selected.emit(id)
	hide()

func show_menu(position: Vector2) -> void:
	size = Vector2(300, 100)
	var rect = Rect2i(position.x, position.y, size.x, size.y)
	popup(rect)
