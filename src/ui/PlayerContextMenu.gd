class_name PlayerContextMenu
extends PopupMenu

signal option_selected(option: String)

var _player_ref: Player = null
var _visual_ref: PlayerVisual = null

func _ready() -> void:
	add_theme_font_size_override("font_size", 24)
	id_pressed.connect(_on_item_selected)
	_rebuild_menu()

func _rebuild_menu() -> void:
	clear()
	
	# Стрельба / Ожидание (toggle)
	if _visual_ref and _visual_ref.is_handle_extended():
		add_item("⏸️ Ожидание", 0)
	else:
		add_item("🔫 Стрельба", 0)
	
	add_item("↔️ Сменить направление", 1)
	add_item("📏 Изменить длину луча", 2)
	
	if _player_ref and _player_ref.status == Player.Status.ELIMINATED:
		add_item("⭕ Поражен", 3)
	else:
		add_item("🟢 В игре", 3)
	
	add_item("🗑️ Удалить игрока", 4)

func _on_item_selected(id: int) -> void:
	match id:
		0:
			if _visual_ref and _visual_ref.is_handle_extended():
				option_selected.emit("hide_handle")
			else:
				option_selected.emit("extend")
		1:
			option_selected.emit("switch_origin")
		2:
			option_selected.emit("adjust_ray")
		3:
			if _player_ref:
				option_selected.emit("toggle_status")
		4:
			option_selected.emit("delete")
	hide()

func show_menu(player: Player, visual: PlayerVisual, position: Vector2) -> void:
	_player_ref = player
	_visual_ref = visual
	_rebuild_menu()
	
	size = Vector2(320, 190)
	var rect = Rect2i(position.x, position.y, size.x, size.y)
	popup(rect)
