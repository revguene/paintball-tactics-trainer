extends Control
class_name MainMenu

## Главное меню редактора

signal new_document()
signal open_image(path: String)
signal save_document(path: String)
signal load_document(path: String)

var _file_dialog: FileDialog = null

func _ready() -> void:
	_setup_file_dialog()

func _setup_file_dialog() -> void:
	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	add_child(_file_dialog)
	
	# Подключаем сигналы
	_file_dialog.file_selected.connect(_on_file_selected)
	_file_dialog.canceled.connect(_on_file_dialog_canceled)

func _on_file_selected(path: String) -> void:
	# Определяем тип файла по расширению
	var extension = path.get_extension().to_lower()
	
	if extension in ["png", "jpg", "jpeg"]:
		open_image.emit(path)
	elif extension == "ptf":
		load_document.emit(path)

func _on_file_dialog_canceled() -> void:
	print("Выбор файла отменён")

## Открыть изображение
func _on_open_image_pressed() -> void:
	_file_dialog.title = "Открыть изображение поля"
	_file_dialog.add_filter("*.png ; *.jpg ; *.jpeg", "Изображения")
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.popup_centered()

## Открыть документ
func _on_open_document_pressed() -> void:
	_file_dialog.title = "Открыть документ .ptf"
	_file_dialog.add_filter("*.ptf", "Paintball Tactical File")
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.popup_centered()

## Сохранить документ
func _on_save_document_pressed() -> void:
	var save_dialog = FileDialog.new()
	save_dialog.title = "Сохранить документ"
	save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_dialog.add_filter("*.ptf", "Paintball Tactical File")
	save_dialog.access = FileDialog.ACCESS_FILESYSTEM
	save_dialog.file_selected.connect(_on_save_file_selected)
	add_child(save_dialog)
	save_dialog.popup_centered()

func _on_save_file_selected(path: String) -> void:
	if not path.ends_with(".ptf"):
		path += ".ptf"
	save_document.emit(path)
