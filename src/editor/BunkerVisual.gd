class_name BunkerVisual
extends Node2D

var bunker: Bunker
var is_selected: bool = false

func _ready() -> void:
	update_visual()

func setup(p_bunker: Bunker) -> void:
	bunker = p_bunker
	position = bunker.position
	update_visual()

func update_visual() -> void:
	# Очищаем старые дети
	for child in get_children():
		child.queue_free()
	
	# Рисуем кружок
	var circle := ColorRect.new()
	circle.size = Vector2(24, 24)
	circle.position = -Vector2(12, 12)
	
	if is_selected:
		circle.color = Color(1, 0.5, 0, 1)  # Оранжевый при выделении
	else:
		circle.color = Color(0.2, 0.6, 1, 1)  # Синий
	
	add_child(circle)
	
	# Рисуем номер ID
	var label := Label.new()
	label.text = str(bunker.type)
	label.position = -Vector2(8, 8)
	label.add_theme_font_size_override("font_size", 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(label)

func select() -> void:
	is_selected = true
	update_visual()

func deselect() -> void:
	is_selected = false
	update_visual()
