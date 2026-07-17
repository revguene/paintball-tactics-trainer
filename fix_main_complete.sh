#!/bin/bash

echo "🔧 Исправление Main.gd..."

# 1. Исправляем порядок аргументов в setup()
sed -i 's/_game_engine.setup(_player_editor, _field_editor, field)/_game_engine.setup(_field_editor, _player_editor, field)/g' scenes/Main.gd

# 2. Добавляем недостающие функции-заглушки (если их нет)
if ! grep -q "func _on_game_state_changed" scenes/Main.gd; then
cat >> scenes/Main.gd << 'ENDOFFUNC'

# ===== ЗАГЛУШКИ ДЛЯ ОТСУТСТВУЮЩИХ ФУНКЦИЙ =====

func _on_game_state_changed(new_state: int) -> void:
	print("📊 Состояние игры: ", new_state)

func _on_game_over(message: String) -> void:
	print("🏁 ", message)

func _on_player_eliminated(player_number: int, team: int) -> void:
	print("💀 Игрок ", player_number, " eliminated!")

func _on_breakout_complete() -> void:
	print("🏃 Разбежка завершена!")

func _setup_load_dialog() -> void:
	_load_dialog = FileDialog.new()
	_load_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_load_dialog.access = FileDialog.ACCESS_FILESYSTEM
	add_child(_load_dialog)
	_load_dialog.file_selected.connect(_on_file_selected)
	_load_dialog.canceled.connect(_on_file_dialog_canceled)

func _setup_field_context_menu() -> void:
	_field_context_menu = FieldContextMenu.new()
	_field_context_menu.option_selected.connect(_on_field_context_menu_selected)
	add_child(_field_context_menu)

func _on_file_selected(path: String) -> void:
	print("📂 Файл выбран: ", path)

func _on_file_dialog_canceled() -> void:
	print("❌ Выбор файла отменен")

func _on_field_context_menu_selected(option: String) -> void:
	print("📋 Выбрано: ", option)

func _on_edit_field_signal() -> void:
	print("✏️ Редактирование поля")

func _on_save_project(path: String) -> void:
	print("💾 Сохранение проекта: ", path)

func _on_load_project(path: String) -> void:
	print("📂 Загрузка проекта: ", path)

func _on_game_mode() -> void:
	print("🎮 Запуск игрового режима")

func _on_memorize_tick(time_left: float) -> void:
	pass

func load_field(path: String) -> void:
	print("📂 Загрузка поля: ", path)

func save_document(path: String) -> void:
	print("💾 Сохранение документа: ", path)

func load_document(path: String) -> void:
	print("📂 Загрузка документа: ", path)

func is_field_editor() -> bool:
	return true

func is_tactical_editor() -> bool:
	return true

func is_game() -> bool:
	return true

func enter_field_editor() -> void:
	pass

func enter_tactical_editor() -> void:
	pass

func enter_game_mode_only() -> void:
	pass

func enter_game() -> void:
	pass

func get_field() -> Field:
	return field

func is_calibrated() -> bool:
	return field.calibrated

func _process(delta: float) -> void:
	pass
ENDOFFUNC
fi

# 3. Добавляем правильную функцию _on_game_phase_changed
sed -i '/^func _on_game_phase_changed/,/^}/d' scenes/Main.gd

cat >> scenes/Main.gd << 'ENDOFFUNC'

func _on_game_phase_changed(phase: int) -> void:
	print("📊 Фаза игры изменена: ", phase)
	
	if _end_turn_button:
		match phase:
			0:
				_end_turn_button.visible = false
				if hint:
					hint.text = "🏃 Разбежка! AI занимает укрытия..."
			1:
				_end_turn_button.visible = true
				_end_turn_button.text = "⏭️ ЗАВЕРШИТЬ ХОД"
				_end_turn_button.modulate = Color(0.2, 0.8, 0.2, 1.0)
				if hint:
					hint.text = "🎯 Ваш ход! Двигайте игроков"
			2:
				_end_turn_button.visible = false
				if hint:
					hint.text = "🤖 Ход компьютера..."
			4:
				_end_turn_button.visible = false
				if hint:
					hint.text = "🏁 Игра окончена!"
			_:
				_end_turn_button.visible = false
ENDOFFUNC

# 4. Добавляем функцию _on_start_button_pressed если ее нет
if ! grep -q "func _on_start_button_pressed" scenes/Main.gd; then
cat >> scenes/Main.gd << 'ENDOFFUNC'

func _on_start_button_pressed() -> void:
	print("▶️ Нажата кнопка СТАРТ!")
	_start_button.visible = false
	
	if _game_engine:
		_game_engine.start_game()
	else:
		print("❌ GameEngine не инициализирован!")
ENDOFFUNC
fi

# 5. Добавляем функцию _on_end_turn_pressed если ее нет
if ! grep -q "func _on_end_turn_pressed" scenes/Main.gd; then
cat >> scenes/Main.gd << 'ENDOFFUNC'

func _on_end_turn_pressed() -> void:
	print("⏭️ Игрок нажал 'Завершить ход'!")
	_end_turn_button.visible = false
	
	if _game_engine:
		_game_engine.finish_player_turn()
	else:
		print("❌ GameEngine не найден!")
ENDOFFUNC
fi

echo "✅ Исправление завершено!"
