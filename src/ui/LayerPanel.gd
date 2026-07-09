extends VBoxContainer
class_name LayerPanel

## Панель слоёв

var _document: Document = null

func setup(document: Document) -> void:
	_document = document
	_update_layers()

func _update_layers() -> void:
	# Очищаем старые слои
	for child in get_children():
		child.queue_free()
	
	if not _document:
		return
	
	# Добавляем слои
	for layer in _document.layers:
		var layer_item = _create_layer_item(layer)
		add_child(layer_item)

func _create_layer_item(layer: Layer) -> Control:
	var container = HBoxContainer.new()
	
	# Checkbox видимости
	var visibility_check = CheckBox.new()
	visibility_check.button_pressed = layer.visible
	visibility_check.toggled.connect(_on_visibility_toggled.bind(layer))
	container.add_child(visibility_check)
	
	# Название слоя
	var name_label = Label.new()
	name_label.text = layer.name
	container.add_child(name_label)
	
	# Индикатор блокировки
	if layer.locked:
		var lock_label = Label.new()
		lock_label.text = "🔒"
		container.add_child(lock_label)
	
	return container

func _on_visibility_toggled(visible: bool, layer: Layer) -> void:
	layer.set_visible(visible)
	print("Слой '%s' видимость: %s" % [layer.name, visible])
