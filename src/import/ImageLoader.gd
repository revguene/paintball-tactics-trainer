extends RefCounted

## Загрузчик изображений для полей
## Поддерживает: PNG, JPG, JPEG

signal image_loaded(path: String, texture: Texture2D)
signal image_load_failed(path: String, error: String)

const SUPPORTED_EXTENSIONS = ["png", "jpg", "jpeg"]

## Загрузить изображение из файла
func load_image(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		image_load_failed.emit(path, "Не удалось открыть файл")
		return
	
	# Проверяем расширение
	var extension = path.get_extension().to_lower()
	if extension not in SUPPORTED_EXTENSIONS:
		image_load_failed.emit(path, "Неподдерживаемый формат: " + extension)
		return
	
	# Загружаем как Image
	var image = Image.new()
	var error = image.load(path)
	
	if error != OK:
		image_load_failed.emit(path, "Ошибка загрузки изображения: " + str(error))
		return
	
	# Создаём Texture2D
	var texture = ImageTexture.create_from_image(image)
	image_loaded.emit(path, texture)

## Проверить, поддерживается ли расширение
func is_supported(path: String) -> bool:
	var extension = path.get_extension().to_lower()
	return extension in SUPPORTED_EXTENSIONS

## Получить список поддерживаемых расширений
func get_supported_extensions() -> String:
	return "*.png;*.jpg;*.jpeg"
