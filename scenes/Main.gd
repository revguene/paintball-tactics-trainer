extends Node2D

@onready var field_image: Sprite2D = $Field/FieldImage
@onready var background: ColorRect = $UI/Background
@onready var title: Label = $UI/Title
@onready var subtitle: Label = $UI/Subtitle
@onready var hint: Label = $UI/Hint

var _document: Document = null

func _ready() -> void:
	print("Paintball Tactical Editor v0.1.0")
	print("Sprint 2 - Image Import & Document Editor")
	
	_document = Document.new()
	_document.name = "Untitled"
	
	var ui = $UI
	if ui:
		var main_menu = ui.get_node("MainMenu")
		if main_menu:
			main_menu.open_image.connect(_on_open_image)
			main_menu.save_document.connect(_on_save_document)
			main_menu.load_document.connect(_on_load_document)
			print("✅ MainMenu подключён")

func load_field(path: String) -> void:
	var texture := ImageLoader.load_texture(path)
	
	if texture == null:
		print("❌ Не удалось загрузить изображение: %s" % path)
		return
	
	# Скрываем приветственный экран
	background.visible = false
	title.visible = false
	subtitle.visible = false
	hint.visible = false
	
	field_image.texture = texture
	field_image.centered = true
	_document.image_path = path
	_fit_image_to_view()
	print("✅ Изображение загружено: %s" % path)

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

func _on_open_image(path: String) -> void:
	load_field(path)

func _on_save_document(path: String) -> void:
	save_document(path)

func _on_load_document(path: String) -> void:
	load_document(path)

func save_document(path: String) -> void:
	var err = _document.save(path)
	if err == OK:
		print("✅ Документ сохранён: %s" % path)
	else:
		print("❌ Ошибка сохранения: %s" % err)

func load_document(path: String) -> void:
	var loaded := Document.load(path)
	if loaded:
		_document = loaded
		if _document.image_path and _document.image_path != "":
			load_field(_document.image_path)
		print("✅ Документ загружен: %s" % path)
	else:
		print("❌ Ошибка загрузки документа: %s" % path)
