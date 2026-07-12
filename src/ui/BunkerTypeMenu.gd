class_name BunkerTypeMenu
extends PopupMenu

signal type_selected(type: int)

func _ready() -> void:
	# Увеличиваем шрифт и делаем его более чётким
	add_theme_font_size_override("font_size", 28)
	
	# Делаем шрифт жирным для чёткости
	var font = ThemeDB.fallback_font
	if font:
		add_theme_font_override("font", font)
	
	_rebuild_menu()

func _rebuild_menu() -> void:
	clear()
	
	var types = BunkerType.get_all_types()
	for i in range(types.size()):
		var type = types[i]
		var name = BunkerType.get_display_name(type)
		add_item(name, type)
	
	id_pressed.connect(_on_item_selected)

func _on_item_selected(id: int) -> void:
	type_selected.emit(id)
	hide()

func show_menu(position: Vector2) -> void:
	# Ширина в 2 раза меньше (было 900, стало 450)
	size = Vector2(450, 700)
	var rect = Rect2i(position.x, position.y, size.x, size.y)
	popup(rect)
