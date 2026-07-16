class_name FieldContextMenu
extends PopupMenu

signal option_selected(option: String)

func _ready() -> void:
	add_theme_font_size_override("font_size", 24)
	
	add_item("🔴 Поставить RED (слева)", 0)
	add_item("🔵 Поставить BLUE (справа)", 1)
	add_item("👥 Поставить обе команды", 2)
	add_item("🔄 Сменить стороны", 3)
	add_item("🗑️ Очистить всех", 4)
	
	id_pressed.connect(_on_item_selected)

func _on_item_selected(id: int) -> void:
	match id:
		0:
			option_selected.emit("spawn_red")
		1:
			option_selected.emit("spawn_blue")
		2:
			option_selected.emit("spawn_both")
		3:
			option_selected.emit("switch_sides")
		4:
			option_selected.emit("clear_all")
	hide()

func show_menu(position: Vector2) -> void:
	size = Vector2(300, 200)
	var rect = Rect2i(position.x - 150, position.y - 100, size.x, size.y)
	popup(rect)
