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
	
	print("========== БУНКЕРЫ ==========")
	var count = 0
	for child in field_editor.get_children():
		if child is Bunker:
			count += 1
			print("Бункер ", count, ": ", BunkerType.get_display_name(child.bunker_type),
				  " | позиция: (", child.field_position.x, ", ", child.field_position.y, ")")
	
	print("Всего бункеров: ", count)
	print("==============================")
	get_tree().quit()
