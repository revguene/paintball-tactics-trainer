extends Node2D

@onready var field_image: Sprite2D = $Field/FieldImage
@onready var background: ColorRect = $UI/Background
@onready var title: Label = $UI/Title
@onready var subtitle: Label = $UI/Subtitle
@onready var hint: Label = $UI/Hint

var _document: Document = null
var _field_editor: FieldEditor = null
var field := Field.new()
var calibration_step := 0
var corners := []
var marker_nodes := []
var calibration_active := false
var current_image_path: String = ""

var center_line: Line2D = null
var is_dragging_center := false
var drag_start_pos: Vector2 = Vector2.ZERO
var drag_start_center: Vector2 = Vector2.ZERO
var center_drag_enabled := false

var editor_mode: int = EditorMode.Mode.FIELD_EDITOR

func _ready() -> void:
	print("Paintball Tactical Editor v0.1.0")
	print("Sprint 4 - Field Editor")
	
	_document = Document.new()
	_document.name = "Untitled"
	
	_field_editor = $FieldEditor
	if _field_editor:
		print("✅ FieldEditor готов")
	
	var ui = $UI
	if ui:
		var main_menu = ui.get_node("MainMenu")
		if main_menu:
			main_menu.edit_field.connect(_on_edit_field_signal)
			main_menu.save_project.connect(_on_save_project)
			main_menu.load_project.connect(_on_load_project)
			main_menu.game_mode.connect(_on_game_mode)
			print("✅ MainMenu подключён")
	
	if hint:
		hint.add_theme_font_size_override("font_size", 42)
		hint.text = "Нажмите «Edit Field» чтобы загрузить изображение поля"
		calibration_active = false
		center_drag_enabled = false

func enter_field_editor() -> void:
	editor_mode = EditorMode.Mode.FIELD_EDITOR
	print("🔧 Режим: FIELD EDITOR")

func enter_tactical_editor() -> void:
	editor_mode = EditorMode.Mode.TACTICAL_EDITOR
	print("🎯 Режим: TACTICAL EDITOR")

func enter_game() -> void:
	editor_mode = EditorMode.Mode.GAME
	print("🎮 Режим: GAME")

func is_field_editor() -> bool:
	return editor_mode == EditorMode.Mode.FIELD_EDITOR

func is_tactical_editor() -> bool:
	return editor_mode == EditorMode.Mode.TACTICAL_EDITOR

func is_game() -> bool:
	return editor_mode == EditorMode.Mode.GAME

func _on_edit_field_signal() -> void:
	enter_field_editor()

func _on_save_project() -> void:
	save_document("user://project.ptf")

func _on_load_project() -> void:
	enter_tactical_editor()
	load_document("user://project.ptf")

func _on_game_mode() -> void:
	enter_game()
	load_document("user://project.ptf")

func load_field(path: String) -> void:
	if not is_field_editor():
		print("⚠️ Редактирование поля доступно только в FIELD_EDITOR режиме")
		return
	
	var texture := ImageLoader.load_texture(path)
	
	if texture == null:
		print("❌ Не удалось загрузить изображение: %s" % path)
		return
	
	current_image_path = path
	_clear_bunkers()
	_remove_center_line()
	
	background.visible = false
	title.visible = false
	subtitle.visible = false
	
	field_image.texture = texture
	field_image.centered = true
	_document.image_path = path
	_fit_image_to_view()
	
	_calibration_reset()
	calibration_active = true
	center_drag_enabled = false
	
	if hint:
		hint.text = "КАЛИБРОВКА (5 точек):\n1. Левый верхний → 2. Правый верхний → 3. Правый нижний → 4. Левый нижний → 5. Центр поля"
		hint.visible = true
	
	print("✅ Изображение загружено: %s" % path)

func _remove_center_line() -> void:
	if center_line:
		center_line.queue_free()
		center_line = null

func _draw_center_line() -> void:
	_remove_center_line()
	
	if not field.calibrated:
		return
	
	var center_px = field.get_center_pixel()
	var top_y = field.top_left.y
	var bottom_y = field.bottom_left.y
	
	center_line = Line2D.new()
	center_line.add_point(Vector2(center_px.x, top_y))
	center_line.add_point(Vector2(center_px.x, bottom_y))
	center_line.width = 1.5
	center_line.default_color = Color(1.0, 0.0, 0.0, 0.6)
	add_child(center_line)
	print("✅ Центральная линия нарисована: X=%.1f" % center_px.x)
	
	center_drag_enabled = true

func _clear_bunkers() -> void:
	if _field_editor:
		for child in _field_editor.get_children():
			if child is Bunker:
				child.queue_free()

func _fit_image_to_view() -> void:
	if field_image.texture == null:
		return
	
	var viewport_size = get_viewport().get_visible_rect().size
	var image_size = Vector2(
		field_image.texture.get_width(),
		field_image.texture.get_height()
	)
	
	if image_size == Vector2.ZERO:
		return
	
	var scale_x = viewport_size.x / image_size.x
	var scale_y = viewport_size.y / image_size.y
	var fit_scale = min(scale_x, scale_y) * 0.85
	
	field_image.scale = Vector2(fit_scale, fit_scale)
	field_image.position = viewport_size / 2
	
	var camera = $Camera2D
	if camera:
		camera.position = viewport_size / 2
		camera.zoom = Vector2(1, 1)

func save_document(path: String) -> void:
	print("💾 Сохранение документа: %s" % path)
	
	if not _field_editor:
		print("❌ FieldEditor не найден")
		return
	
	var bunkers_data = []
	for child in _field_editor.get_children():
		if child is Bunker:
			var field_pos = field.screen_to_field(child.position)
			bunkers_data.append({
				"id": child.id,
				"mirror_id": child.mirror_id,
				"type": child.bunker_type,
				"type_name": BunkerType.get_display_name(child.bunker_type),
				"x": field_pos.x,
				"y": field_pos.y,
				"rotation": child.rotation,
				"is_mirror": child.is_mirror,
				"visible": true
			})
	
	_document.clear_bunkers()
	for data in bunkers_data:
		_document.add_bunker(data)
	
	if field.calibrated:
		_document.set_corners(field.top_left, field.top_right, field.bottom_right, field.bottom_left)
		_document.set_center(field.center_pixel)
	
	_document.image_path = current_image_path
	if field_image.texture:
		var image = field_image.texture.get_image()
		if image:
			var png_data = image.save_png_to_buffer()
			_document.image_data = Marshalls.raw_to_base64(png_data)
	
	var err = ProjectSerializer.save_document(_document, path)
	if err == OK:
		print("✅ Документ сохранён: %s" % path)
	else:
		print("❌ Ошибка сохранения: %s" % err)

func load_document(path: String) -> void:
	print("📂 Загрузка документа: %s" % path)
	
	background.visible = false
	title.visible = false
	subtitle.visible = false
	if hint:
		hint.visible = false
	
	var loaded = ProjectSerializer.load_document(path)
	if not loaded:
		print("❌ Ошибка загрузки документа: %s" % path)
		return
	
	_document = loaded
	
	if _document.has_image_data():
		print("   Восстановление изображения из base64...")
		var image_bytes = Marshalls.base64_to_raw(_document.image_data)
		var image = Image.new()
		var err = image.load_png_from_buffer(image_bytes)
		if err == OK:
			var texture = ImageTexture.create_from_image(image)
			
			field_image.texture = null
			field_image.texture = texture
			field_image.centered = true
			field_image.visible = true
			field_image.show()
			field_image.modulate = Color.WHITE
			
			_fit_image_to_view()
			
			print("✅ Изображение восстановлено из base64")
			print("   Размер: %s x %s" % [texture.get_width(), texture.get_height()])
		else:
			print("❌ Ошибка восстановления изображения: %s" % err)
	
	if _document.calibrated:
		field.set_corners(
			_document.top_left,
			_document.top_right,
			_document.bottom_right,
			_document.bottom_left
		)
		field.set_center(_document.center_pixel)
		print("✅ Калибровка восстановлена")
		_draw_center_line()
	
	_clear_bunkers()
	
	var restored_count = 0
	for data in _document.bunkers:
		var pos = Vector2(data["x"], data["y"])
		var screen_pos = field.field_to_screen(pos)
		
		var bunker = Bunker.new()
		bunker.position = screen_pos
		bunker.field_position = pos
		bunker.id = data.get("id", restored_count + 1)
		bunker.mirror_id = data.get("mirror_id", -1)
		
		# Преобразуем тип из строки в enum
		var type_str = data.get("type_name", "Giant Block")
		var found_type = BunkerType.Type.GIANT_BLOCK
		for t in BunkerType.get_all_types():
			if BunkerType.get_display_name(t) == type_str:
				found_type = t
				break
		bunker.bunker_type = found_type
		
		bunker.is_mirror = data.get("is_mirror", false)
		bunker.rotation = data.get("rotation", 0.0)
		
		_field_editor.add_child(bunker)
		bunker.queue_redraw()
		restored_count += 1
		print("✅ Восстановлен бункер %d: (%.2f, %.2f)" % [bunker.id, pos.x, pos.y])
	
	print("✅ Восстановлено укрытий: %s" % restored_count)
	print("✅ Документ загружен: %s" % path)

func _input(event: InputEvent) -> void:
	if not calibration_active:
		_handle_center_drag(event)
		return
	
	if is_field_editor() and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		_add_point(mouse_pos)

func _add_point(pos: Vector2) -> void:
	if not is_field_editor():
		return
	
	calibration_step += 1
	
	var marker = ColorRect.new()
	marker.size = Vector2(8, 8)
	marker.position = pos - Vector2(4, 4)
	
	if calibration_step <= 4:
		marker.color = Color(0.1, 0.1, 0.5, 1)
		corners.append(pos)
		add_child(marker)
		marker_nodes.append(marker)
		
		print("📍 Угол %d: %s" % [calibration_step, pos])
		
		if hint:
			match calibration_step:
				1:
					hint.text = "✅ Левый верхний.\nТеперь кликните по ПРАВОМУ ВЕРХНЕМУ углу"
				2:
					hint.text = "✅ Правый верхний.\nТеперь кликните по ПРАВОМУ НИЖНЕМУ углу"
				3:
					hint.text = "✅ Правый нижний.\nТеперь кликните по ЛЕВОМУ НИЖНЕМУ углу"
				4:
					hint.text = "✅ Левый нижний.\nТеперь кликните по ЦЕНТРУ ПОЛЯ"
	else:
		_finish_calibration(pos)

func _finish_calibration(center: Vector2) -> void:
	if not is_field_editor():
		return
	
	field.set_corners(corners[0], corners[1], corners[2], corners[3])
	field.set_center(center)
	
	_draw_center_line()
	
	print("✅ КАЛИБРОВКА ЗАВЕРШЕНА!")
	print("   Центр поля (пиксели): %s" % center)
	
	for marker in marker_nodes:
		marker.queue_free()
	marker_nodes.clear()
	
	if hint:
		hint.text = ""
		hint.visible = false
	
	calibration_active = false

func _calibration_reset() -> void:
	calibration_step = 0
	corners = []
	field.calibrated = false
	calibration_active = false
	_remove_center_line()
	center_drag_enabled = false
	
	for marker in marker_nodes:
		marker.queue_free()
	marker_nodes.clear()
	
	if hint:
		hint.visible = true
		hint.text = "Нажмите «Edit Field» чтобы загрузить изображение поля"

func _handle_center_drag(event: InputEvent) -> void:
	if not field.calibrated:
		return
	
	if not center_drag_enabled:
		return
	
	if not is_field_editor():
		return
	
	if not center_line:
		return
	
	var mouse_pos = get_global_mouse_position()
	var center_px = field.get_center_pixel()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var dist = abs(mouse_pos.x - center_px.x)
			if dist < 20:
				is_dragging_center = true
				drag_start_pos = mouse_pos
				drag_start_center = center_px
				print("🔴 Перетаскивание центра начато")
			else:
				is_dragging_center = false
		else:
			if is_dragging_center:
				is_dragging_center = false
				print("🔴 Перетаскивание центра завершено")
	
	if event is InputEventMouseMotion and is_dragging_center:
		var delta_x = mouse_pos.x - drag_start_pos.x
		var new_center_x = drag_start_center.x + delta_x
		
		var min_x = field.top_left.x + 20
		var max_x = field.top_right.x - 20
		new_center_x = clamp(new_center_x, min_x, max_x)
		
		var new_center = Vector2(new_center_x, field.get_center_pixel().y)
		field.center_pixel = new_center
		
		_draw_center_line()
		
		print("📍 Центр перемещён: X=%.1f" % new_center_x)

func get_field() -> Field:
	return field

func is_calibrated() -> bool:
	return field.calibrated
