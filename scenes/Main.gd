extends Node2D

## Главная сцена редактора

var _document: Document = null
var _image_loader: ImageLoader = null
var _field_view: FieldView = null

func _ready() -> void:
	print("Paintball Tactical Editor v0.1.0")
	print("Sprint 2 - Image Import & Document Editor")
	
	# Инициализация
	_document = Document.new()
	_image_loader = ImageLoader.new()
	_field_view = $FieldView
	
	# Подключение сигналов
	_image_loader.image_loaded.connect(_on_image_loaded)
	_image_loader.image_load_failed.connect(_on_image_load_failed)
	
	# Настройка камеры
	var camera = $Camera2D
	if camera:
		camera.position = get_viewport().get_visible_rect().size / 2
		camera.zoom = Vector2(1, 1)
	
	# Создаём новый документ
	_create_new_document()

func _create_new_document() -> void:
	_document = Document.new()
	_field_view.clear_image()
	print("Создан новый документ")

func _on_image_loaded(path: String, texture: Texture2D) -> void:
	_document.set_image(path, texture)
	_field_view.set_image(texture)
	
	# Масштабируем изображение под размер окна
	_fit_image_to_view()
	
	print("Изображение загружено: %s" % path)

func _on_image_load_failed(path: String, error: String) -> void:
	print("Ошибка загрузки: %s - %s" % [path, error])
	# TODO: Показать сообщение пользователю

func _fit_image_to_view() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var image_size = _field_view.get_image_size()
	
	if image_size == Vector2.ZERO:
		return
	
	# Вычисляем масштаб чтобы изображение поместилось в окно
	var scale_x = viewport_size.x / image_size.x
	var scale_y = viewport_size.y / image_size.y
	var fit_scale = min(scale_x, scale_y) * 0.9  # 0.9 для отступа
	
	var camera = $Camera2D
	if camera:
		camera.zoom = Vector2(fit_scale, fit_scale)
		camera.position = viewport_size / 2

func _input(event: InputEvent) -> void:
	# Zoom колесиком мыши
	if event is InputEventMouseButton:
		var camera = $Camera2D
		if camera and _field_view.has_image():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				camera.zoom *= 1.1
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				camera.zoom *= 0.9
				camera.zoom = camera.zoom.clamp(Vector2(0.1, 0.1), Vector2(10, 10))
	
	# Pan (перемещение) средней кнопкой мыши
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		var camera = $Camera2D
		if camera:
			camera.position -= event.relative / camera.zoom

## Открыть изображение (вызывается из меню)
func open_image(path: String) -> void:
	_image_loader.load_image(path)

## Сохранить документ (вызывается из меню)
func save_document(path: String) -> void:
	# TODO: Реализовать сохранение .ptf
	print("Сохранение документа в: %s" % path)

## Загрузить документ (вызывается из меню)
func load_document(path: String) -> void:
	# TODO: Реализовать загрузку .ptf
	print("Загрузка документа из: %s" % path)
