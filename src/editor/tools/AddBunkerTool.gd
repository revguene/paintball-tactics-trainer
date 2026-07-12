class_name AddBunkerTool
extends BaseTool

static var NEXT_ID := 1

var type_menu: BunkerTypeMenu = null

func _init(p_editor: FieldEditor = null) -> void:
	super(p_editor)
	_create_type_menu()

func _create_type_menu() -> void:
	type_menu = BunkerTypeMenu.new()
	type_menu.type_selected.connect(_on_type_selected)
	if editor:
		editor.add_child(type_menu)

func _input(event: InputEvent) -> void:
	if not editor:
		return
	
	var tree = editor.get_tree()
	if not tree:
		return
	
	var main = tree.current_scene
	if not main or not main.has_method("is_field_editor"):
		return
	
	if not main.is_field_editor():
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var screen_pos := editor.get_global_mouse_position()
		var field = editor.get_field()
		
		if not field or not field.calibrated:
			print("❌ Поле не откалибровано!")
			return
		
		var field_pos = field.screen_to_field(screen_pos)
		
		if not field.is_point_inside(field_pos):
			print("⚠️ Точка за пределами поля!")
			return
		
		var global_pos = editor.get_global_mouse_position()
		type_menu.show_menu(global_pos)
		_current_pos = screen_pos
		_current_field_pos = field_pos

var _current_pos: Vector2 = Vector2.ZERO
var _current_field_pos: Vector2 = Vector2.ZERO

func _on_type_selected(type: int) -> void:
	_create_bunker(_current_pos, _current_field_pos, type)
	if editor.has_method("set_tool"):
		editor.set_tool("Select")

func _create_bunker(screen_pos: Vector2, field_pos: Vector2, type: int) -> void:
	var field = editor.get_field()
	if not field or not field.calibrated:
		return
	
	# Основной бункер
	var first = Bunker.new()
	first.position = screen_pos
	first.field_position = field_pos
	first.id = _generate_id()
	first.bunker_type = type
	first.is_mirror = false
	first.rotation = 0
	editor.add_child(first)
	first.queue_redraw()
	print("✅ Бункер %s создан на позиции: %.2f м, %.2f м" % [BunkerType.get_display_name(type), field_pos.x, field_pos.y])
	
	# Зеркальный бункер — ТОЛЬКО относительно центральной линии (без WIDTH!)
	var mirror_screen_pos = field.mirror_screen_position(screen_pos)
	var mirror_field_pos = field.screen_to_field(mirror_screen_pos)
	
	if field.is_point_inside(mirror_field_pos):
		var mirror = Bunker.new()
		mirror.position = mirror_screen_pos
		mirror.field_position = mirror_field_pos
		mirror.id = _generate_id()
		mirror.bunker_type = type
		mirror.is_mirror = true
		mirror.rotation = 0
		
		mirror.mirror_id = first.id
		first.mirror_id = mirror.id
		
		editor.add_child(mirror)
		mirror.queue_redraw()
		print("✅ Зеркальный бункер %s создан на позиции: %.2f м, %.2f м" % [BunkerType.get_display_name(type), mirror_field_pos.x, mirror_field_pos.y])
	else:
		print("⚠️ Зеркальная точка за пределами поля!")

func _generate_id() -> int:
	var id = NEXT_ID
	NEXT_ID += 1
	return id
