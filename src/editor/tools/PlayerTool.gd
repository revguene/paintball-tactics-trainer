class_name PlayerTool
extends BaseTool

var type_menu: PlayerTypeMenu = null

func _init(p_editor: FieldEditor = null) -> void:
	super(p_editor)
	_create_type_menu()

func _create_type_menu() -> void:
	type_menu = PlayerTypeMenu.new()
	type_menu.player_selected.connect(_on_player_selected)
	if editor:
		editor.add_child(type_menu)

func _input(event: InputEvent) -> void:
	if not editor:
		return
	
	var tree = editor.get_tree()
	if not tree:
		return
	
	var main = tree.current_scene
	if not main or not main.has_method("is_tactical_editor"):
		return
	
	if not main.is_tactical_editor():
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos := editor.get_global_mouse_position()
		
		var player_editor = main.get_node_or_null("PlayerEditor")
		if not player_editor:
			print("❌ PlayerEditor не найден!")
			return
		
		# Проверяем лимит
		if player_editor.get_player_count() >= 10:
			print("⚠️ Достигнут лимит игроков (10)")
			return
		
		# Показываем меню выбора команды
		type_menu.show_menu(mouse_pos)
		_current_pos = mouse_pos

var _current_pos: Vector2 = Vector2.ZERO

func _on_player_selected(team: int) -> void:
	var tree = editor.get_tree()
	if not tree:
		return
	
	var main = tree.current_scene
	if not main:
		return
	
	var player_editor = main.get_node_or_null("PlayerEditor")
	if not player_editor:
		print("❌ PlayerEditor не найден!")
		return
	
	# Проверяем лимит команды
	var team_count = player_editor.get_team_count(team)
	if team_count >= 5:
		print("⚠️ В команде уже 5 игроков")
		return
	
	# Создаём игрока
	player_editor.create_player(team, _current_pos)
	
	# Возвращаемся в SELECT режим
	if editor.has_method("set_tool"):
		editor.set_tool("Select")
