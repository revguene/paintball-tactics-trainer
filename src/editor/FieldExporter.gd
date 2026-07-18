class_name FieldExporter
extends RefCounted

static func export_document(editor: FieldEditor, field: Field, document: Document, image_path: String, image_texture: Texture2D) -> Document:
	document.image_path = image_path
	
	if field and field.calibrated:
		document.set_corners(field.top_left, field.top_right, field.bottom_right, field.bottom_left)
		document.set_center(field.center_pixel)
	
	if image_texture:
		var image = image_texture.get_image()
		if image:
			var png_data = image.save_png_to_buffer()
			document.image_data = Marshalls.raw_to_base64(png_data)
	
	document.clear_bunkers()
	for child in editor.get_children():
		if child is Bunker:
			var field_pos = field.screen_to_field(child.position)
			document.add_bunker({
				"id": child.id,
				"mirror_id": child.mirror_id,
				"type": child.bunker_type,
				"type_name": BunkerType.get_display_name(child.bunker_type),
				"x": field_pos.x,
				"y": field_pos.y,
				"rotation": child.rotation,
				"is_mirror": child.is_mirror,
				"visible": true
			})
	
	return document

static func import_document(document: Document, field: Field, editor: FieldEditor) -> void:
	if document.calibrated:
		field.set_corners(
			document.top_left,
			document.top_right,
			document.bottom_right,
			document.bottom_left
		)
		field.set_center(document.center_pixel)
	
	# Очищаем старые укрытия
	for child in editor.get_children():
		if child is Bunker:
			child.queue_free()
	
	# Восстанавливаем укрытия
	for data in document.bunkers:
		var pos = Vector2(data["x"], data["y"])
		var screen_pos = field.field_to_screen(pos)
		
		var bunker = Bunker.new()
		bunker.position = screen_pos
		bunker.field_position = pos
		bunker.id = data.get("id", 0)
		bunker.mirror_id = data.get("mirror_id", -1)
		bunker.bunker_type = data.get("type", BunkerType.Type.BRICK)
		bunker.is_mirror = data.get("is_mirror", false)
		bunker.rotation = data.get("rotation", 0.0)
		
		editor.add_child(bunker)
		bunker.queue_redraw()
