class_name MainMenu
extends Control

signal edit_field()
signal save_project()
signal load_project()
signal game_mode()
signal exit_app()

var _file_dialog: FileDialog = null

func _ready() -> void:
	_setup_file_dialog()
	
	# Edit Field
	var btn_edit = Button.new()
	btn_edit.text = "📂 Edit Field"
	btn_edit.position = Vector2(10, 10)
	btn_edit.size = Vector2(130, 45)
	btn_edit.add_theme_font_size_override("font_size", 25)
	btn_edit.pressed.connect(_on_edit_field_pressed)
	add_child(btn_edit)
	
	# Save Project
	var btn_save = Button.new()
	btn_save.text = "💾 Save Project"
	btn_save.position = Vector2(170, 10)
	btn_save.size = Vector2(130, 45)
	btn_save.add_theme_font_size_override("font_size", 25)
	btn_save.pressed.connect(_on_save_project_pressed)
	add_child(btn_save)
	
	# Load Project
	var btn_load = Button.new()
	btn_load.text = "📂 Load Project"
	btn_load.position = Vector2(370, 10)   # Было 350, стало 370
	btn_load.size = Vector2(130, 45)
	btn_load.add_theme_font_size_override("font_size", 25)
	btn_load.pressed.connect(_on_load_project_pressed)
	add_child(btn_load)
	
	# Game
	var btn_game = Button.new()
	btn_game.text = "🎮 Game"
	btn_game.position = Vector2(570, 10)   # Было 530, стало 570
	btn_game.size = Vector2(110, 45)
	btn_game.add_theme_font_size_override("font_size", 25)
	btn_game.pressed.connect(_on_game_pressed)
	add_child(btn_game)
	
	# Exit
	var btn_exit = Button.new()
	btn_exit.text = "🚪 Exit"
	btn_exit.position = Vector2(690, 10)   # Было 650, стало 690
	btn_exit.size = Vector2(110, 45)
	btn_exit.add_theme_font_size_override("font_size", 25)
	btn_exit.pressed.connect(_on_exit_pressed)
	add_child(btn_exit)

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
		edit_field.emit()
		var main = get_tree().current_scene
		if main and main.has_method("load_field"):
			main.load_field(path)
	elif ext == "ptf":
		load_project.emit()

func _on_file_dialog_canceled() -> void:
	print("Выбор файла отменён")

func open_image_dialog() -> void:
	_file_dialog.title = "Выберите изображение поля"
	_file_dialog.add_filter("*.png ; *.jpg ; *.jpeg", "Изображения")
	_file_dialog.popup_centered()

func _on_edit_field_pressed() -> void:
	open_image_dialog()

func _on_save_project_pressed() -> void:
	var save_dialog = FileDialog.new()
	save_dialog.title = "Сохранить проект"
	save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_dialog.add_filter("*.ptf", "Paintball Tactical File")
	save_dialog.access = FileDialog.ACCESS_FILESYSTEM
	save_dialog.file_selected.connect(_on_save_file_selected)
	add_child(save_dialog)
	save_dialog.popup_centered()

func _on_save_file_selected(path: String) -> void:
	if not path.ends_with(".ptf"):
		path += ".ptf"
	save_project.emit()

func _on_load_project_pressed() -> void:
	_file_dialog.title = "Открыть проект .ptf"
	_file_dialog.add_filter("*.ptf", "Paintball Tactical File")
	_file_dialog.popup_centered()

func _on_game_pressed() -> void:
	game_mode.emit()

func _on_exit_pressed() -> void:
	print("🚪 Выход из приложения")
	exit_app.emit()
	get_tree().quit()
