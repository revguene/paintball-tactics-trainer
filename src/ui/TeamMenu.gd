class_name TeamMenu
extends PopupMenu

signal teams_spawned(red_count: int, blue_count: int, red_base: String, blue_base: String, human_team: int)

var _field_ref: Field = null
var _player_editor: PlayerEditor = null
var _main_ref: Node = null
var _editor_ref: FieldEditor = null

func setup(field: Field, player_editor: PlayerEditor, main: Node) -> void:
	_field_ref = field
	_player_editor = player_editor
	_main_ref = main
	if main:
		_editor_ref = main.get_node_or_null("FieldEditor")
	print("✅ TeamMenu setup: field=", field != null, " player_editor=", player_editor != null, " main=", main != null)

func _ready() -> void:
	add_theme_font_size_override("font_size", 24)
	id_pressed.connect(_on_item_selected)

func _rebuild_menu() -> void:
	clear()
	
	add_item("👥 Создать команды (5 RED / 5 BLUE)", 0)
	add_separator()
	add_item("🔴 RED база: ЛЕВАЯ", 1)
	add_item("🔴 RED база: ПРАВАЯ", 2)
	add_separator()
	add_item("🎮 Игрок за: RED", 3)
	add_item("🎮 Игрок за: BLUE", 4)
	add_separator()
	add_item("🔄 Сменить стороны", 5)
	add_item("🗑️ Очистить всех", 6)

func _on_item_selected(id: int) -> void:
	match id:
		0:
			_spawn_teams_along_banners(5, 5, "left", "right", Player.Team.RED)
		1:
			_spawn_teams_along_banners(5, 5, "left", "right", Player.Team.RED)
		2:
			_spawn_teams_along_banners(5, 5, "right", "left", Player.Team.RED)
		3:
			_spawn_teams_along_banners(5, 5, "left", "right", Player.Team.RED)
		4:
			_spawn_teams_along_banners(5, 5, "left", "right", Player.Team.BLUE)
		5:
			_switch_sides()
		6:
			_clear_all()
	hide()

func _spawn_teams_along_banners(red_count: int, blue_count: int, red_base: String, blue_base: String, human_team: int) -> void:
	print("🔧 TeamMenu._spawn_teams_along_banners: red_base=", red_base, " blue_base=", blue_base, " human_team=", human_team)
	
	if not _field_ref or not _field_ref.calibrated:
		print("❌ Поле не откалибровано!")
		return
	
	if not _player_editor:
		print("❌ PlayerEditor не найден!")
		return
	
	if not _editor_ref:
		print("❌ FieldEditor не найден!")
		return
	
	# Ищем ВСЕ баннеры на поле
	var banners: Array = []
	for child in _editor_ref.get_children():
		if child is Bunker and child.bunker_type == BunkerType.Type.BANNER:
			banners.append(child)
	
	if banners.size() < 2:
		print("❌ Найдено меньше 2 баннеров! Нужно 2 баннера (левый и правый)")
		return
	
	# Сортируем баннеры по X
	banners.sort_custom(func(a, b): return a.field_position.x < b.field_position.x)
	
	var left_banner = banners[0]
	var right_banner = banners[1]
	
	print("🏳️ Левый баннер: ", left_banner.field_position)
	print("🏳️ Правый баннер: ", right_banner.field_position)
	
	# Удаляем всех игроков
	_player_editor.clear_players()
	
	# Определяем, кто где стоит
	var red_banner = left_banner
	var blue_banner = right_banner
	
	if red_base == "right":
		red_banner = right_banner
		blue_banner = left_banner
	
	print("   RED у баннера: ", red_banner.field_position)
	print("   BLUE у баннера: ", blue_banner.field_position)
	
	# Расставляем RED вдоль своего баннера
	_player_editor.place_players_along_banner(red_banner, Player.Team.RED, 5)
	
	# Расставляем BLUE вдоль своего баннера
	_player_editor.place_players_along_banner(blue_banner, Player.Team.BLUE, 5)
	
	print("✅ Создано ", red_count, " RED и ", blue_count, " BLUE игроков")
	print("   RED база: ", red_base)
	print("   BLUE база: ", blue_base)
	
	var human_name = "RED" if human_team == Player.Team.RED else "BLUE"
	print("   🎮 Игрок управляет: ", human_name)
	
	if _main_ref and _main_ref.has_method("set_human_team"):
		_main_ref.set_human_team(human_team)

func _switch_sides() -> void:
	if not _player_editor:
		return
	
	for visual in _player_editor.players:
		if visual.player:
			if visual.player.team == Player.Team.RED:
				visual.player.team = Player.Team.BLUE
				visual.player.rotation = PI
			else:
				visual.player.team = Player.Team.RED
				visual.player.rotation = 0.0
			visual.queue_redraw()
	
	print("🔄 Стороны команд поменяны")

func _clear_all() -> void:
	if _player_editor:
		_player_editor.clear_players()
		print("🗑️ Все игроки удалены")

func show_menu(position: Vector2) -> void:
	_rebuild_menu()
	size = Vector2(450, 320)
	var rect = Rect2i(position.x, position.y, size.x, size.y)
	popup(rect)
