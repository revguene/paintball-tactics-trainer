class_name MainMenu
extends Control

signal open_image(path: String)
signal save_document(path: String)
signal load_document(path: String)

var _file_dialog: FileDialog = null

func _ready() -> void:
	_setup_file_dialog()
	
	# Кнопка Open Image — размер текста 25
	var btn_open = Button.new()
	btn_open.text = "📂 Open Image"
	btn_open.position = Vector2(10, 10)
	btn_open.size = Vector2(220, 50)
	btn_open.add_theme_font_size_override("font_size", 25)
	btn_open.pressed.connect(_on_open_image_pressed)
	add_child(btn_open)
	
	# Кнопка Save — размер текста 25
	var btn_save = Button.new()
	btn_save.text = "💾 Save"
	btn_save.position = Vector2(240, 10)
	btn_save.size = Vector2(180, 50)
	btn_save.add_theme_font_size_override("font_size", 25)
	btn_save.pressed.connect(_on_save_document_pressed)
	add_child(btn_save)
	
	# Кнопка Load — размер текста 25
	var btn_load = Button.new()
	btn_load.text = "📂 Load"
	btn_load.position = Vector2(430, 10)
	btn_load.size = Vector2(180, 50)
	btn_load.add_theme_font_size_override("font_size", 25)
	btn_load.pressed.connect(_on_load_document_pressed)
	add_child(btn_load)

func _setup_file_dialog() -> void:
	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	add_child(_file_dialog)
	_file_dialog.file_selected.connect(_on_file_selected)
	_file_dialog.canceled.connect(_on_file_dialog_canceled)

func _on_file_selected(path: String) -> void:
	var ext = path.get_extension().to_lower()
	if ext in ["png", "jpg", "jpeg"]:
		open_image.emit(path)
	elif ext == "ptf":
		load_document.emit(path)

func _on_file_dialog_canceled() -> void:
	print("Выбор файла отменён")

func _on_open_image_pressed() -> void:
	_file_dialog.title = "Выберите изображение поля"
	_file_dialog.add_filter("*.png ; *.jpg ; *.jpeg", "Изображения")
	_file_dialog.popup_centered()

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

func _on_load_document_pressed() -> void:
	_file_dialog.title = "Открыть документ .ptf"
	_file_dialog.add_filter("*.ptf", "Paintball Tactical File")
	_file_dialog.popup_centered()
