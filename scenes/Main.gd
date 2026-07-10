extends Node2D

var _document: Document = null
var _image_loader: ImageLoader = null
var _field_view: FieldView = null

func _ready() -> void:
	print("Paintball Tactical Editor v0.1.0")
	print("Sprint 2 - Image Import & Document Editor")
	
	_document = Document.new()
	_image_loader = ImageLoader.new()
	_field_view = $FieldView
	
	_image_loader.image_loaded.connect(_on_image_loaded)
	_image_loader.image_load_failed.connect(_on_image_load_failed)
	
	_create_new_document()
	
	# Подключаем MainMenu
	var ui = $UI
	if ui:
		var main_menu = ui.get_node("MainMenu")
		if main_menu:
			main_menu.open_image.connect(_on_open_image)
			main_menu.save_document.connect(_on_save_document)
			main_menu.load_document.connect(_on_load_document)
			print("✅ MainMenu подключён")

func _create_new_document() -> void:
	_document = Document.new()
	if _field_view:
		_field_view.clear_image()
	print("Создан новый документ")

func _on_image_loaded(path: String, texture: Texture2D) -> void:
	_document.image_path = path
	_field_view.set_image(texture)
	_fit_image_to_view()
	print("Изображение загружено: %s" % path)

func _on_image_load_failed(path: String, error: String) -> void:
	print("Ошибка загрузки: %s - %s" % [path, error])

func _fit_image_to_view() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var image_size = _field_view.get_image_size()
	
	if image_size == Vector2.ZERO:
		return
	
	var scale_x = viewport_size.x / image_size.x
	var scale_y = viewport_size.y / image_size.y
	var fit_scale = min(scale_x, scale_y) * 0.85
	
	_field_view.set_sprite_scale(Vector2(fit_scale, fit_scale))
	
	# Камера теперь управляется через CameraController
	var camera = $Camera2D
	if camera:
		camera.position = viewport_size / 2
		camera.zoom = Vector2(1, 1)
	
	print("Масштаб спрайта: %s" % fit_scale)

func open_image(path: String) -> void:
	if _image_loader:
		_image_loader.load_image(path)

func _on_open_image(path: String) -> void:
	open_image(path)

func _on_save_document(path: String) -> void:
	save_document(path)

func _on_load_document(path: String) -> void:
	load_document(path)

func save_document(path: String) -> void:
	var saver = DocumentSaver.new()
	saver.save_completed.connect(_on_save_completed)
	saver.save_failed.connect(_on_save_failed)
	saver.save_document(_document, path)

func load_document(path: String) -> void:
	var loader = DocumentLoader.new()
	loader.load_completed.connect(_on_load_completed)
	loader.load_failed.connect(_on_load_failed)
	loader.load_document(path)

func _on_save_completed(path: String) -> void:
	print("✅ Документ сохранён: %s" % path)

func _on_save_failed(path: String, error: String) -> void:
	print("❌ Ошибка сохранения: %s" % error)

func _on_load_completed(document: Document, path: String) -> void:
	_document = document
	if _document.image_path and _document.image_path != "":
		_image_loader.load_image(_document.image_path)
	print("✅ Документ загружен: %s" % path)

func _on_load_failed(path: String, error: String) -> void:
	print("❌ Ошибка загрузки: %s" % error)
