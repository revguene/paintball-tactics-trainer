extends Node2D

func _ready():
	var main = get_tree().current_scene
	if not main:
		print("❌ Main не найден!")
		return
	
	var field_editor = main.get_node_or_null("FieldEditor")
	if not field_editor:
		print("❌ FieldEditor не найден!")
		return
	
	var bunkers = []
	for child in field_editor.get_children():
		if child is Bunker:
			bunkers.append(child)
			print("✅ Бункер: ", BunkerType.get_display_name(child.bunker_type), 
				  " на позиции (", child.field_position.x, ", ", child.field_position.y, ")")
	
	print("Всего бункеров: ", bunkers.size())
	
	if bunkers.is_empty():
		print("❌ НЕТ БУНКЕРОВ! Загрузите поле с укрытиями или добавьте их вручную")
	else:
		print("✅ Найдено ", bunkers.size(), " бункеров")
