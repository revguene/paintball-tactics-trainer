class_name SelectTool
extends BaseTool

var dragging := false
var is_rotating := false
var drag_offset := Vector2.ZERO
var selected_bunker: Bunker = null
var mirror_bunker: Bunker = null

func _input(event: InputEvent) -> void:
	if not editor:
		return
	
	var tree = editor.get_tree()
	if not tree:
		return
	
	var main = tree.current_scene
	if not main or not main.has_method("is_field_editor"):
		return
	
	if not main.is_field_editor():
		return
	
	var mouse_pos := editor.get_global_mouse_position()
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if Input.is_key_pressed(KEY_SPACE):
					return
				
				var clicked = _get_bunker_at(mouse_pos)
				if clicked:
					if clicked != selected_bunker:
						_deselect_all()
						selected_bunker = clicked
						selected_bunker.select()
						print("✅ Выделен бункер ID: %s" % selected_bunker.id)
					
					dragging = true
					drag_offset = mouse_pos - selected_bunker.position
					mirror_bunker = _get_mirror_bunker(selected_bunker)
				else:
					_deselect_all()
					dragging = false
			else:
				if is_rotating:
					is_rotating = false
					if selected_bunker:
						selected_bunker.rotating = false
						selected_bunker.queue_redraw()
					print("🔄 Вращение завершено")
				dragging = false
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed and selected_bunker:
				is_rotating = true
				selected_bunker.rotating = true
				print("🔄 Вращение начато (ПКМ)")
			else:
				if is_rotating:
					is_rotating = false
					if selected_bunker:
						selected_bunker.rotating = false
						selected_bunker.queue_redraw()
					print("🔄 Вращение завершено")
	
	if event is InputEventMouseMotion:
		if is_rotating and selected_bunker and selected_bunker.rotating:
			_rotate_bunker(mouse_pos)
		elif dragging and selected_bunker and not is_rotating:
			_move_bunker(mouse_pos)
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE:
			if selected_bunker:
				_remove_bunker(selected_bunker)

func _rotate_bunker(mouse_pos: Vector2) -> void:
	if not selected_bunker:
		return
	
	var center = selected_bunker.global_position
	var v = mouse_pos - center
	
	if v.length() < 20.0:
		return
	
	var angle = v.angle()
	selected_bunker.rotation = angle
	selected_bunker.queue_redraw()
	
	_sync_mirror(selected_bunker)

func _move_bunker(mouse_pos: Vector2) -> void:
	if not selected_bunker:
		return
	
	var field = editor.get_field()
	if not field or not field.calibrated:
		return
	
	var new_screen_pos = mouse_pos - drag_offset
	var field_pos = field.screen_to_field(new_screen_pos)
	field_pos.x = clamp(field_pos.x, 0.0, Field.WIDTH)
	field_pos.y = clamp(field_pos.y, 0.0, Field.HEIGHT)
	
	new_screen_pos = field.field_to_screen(field_pos)
	
	selected_bunker.position = new_screen_pos
	selected_bunker.field_position = field_pos
	
	_sync_mirror(selected_bunker)

func _sync_mirror(bunker: Bunker) -> void:
	var field = editor.get_field()
	if not field or not field.calibrated:
		return
	
	if not mirror_bunker or not is_instance_valid(mirror_bunker):
		mirror_bunker = _get_mirror_bunker(bunker)
		if not mirror_bunker:
			return
	
	var center_px = field.get_center_pixel()
	var dx = bunker.position.x - center_px.x
	var mirror_pos = Vector2(center_px.x - dx, bunker.position.y)
	
	mirror_bunker.position = mirror_pos
	
	var mirror_field_pos = field.screen_to_field(mirror_pos)
	mirror_bunker.field_position = mirror_field_pos
	
	var mirror_angle = -bunker.rotation
	mirror_bunker.rotation = mirror_angle
	
	mirror_bunker.queue_redraw()

func _get_bunker_at(pos: Vector2) -> Bunker:
	var best: Bunker = null
	var best_dist: float = INF
	
	for child in editor.get_children():
		if child is Bunker:
			if child.is_mirror:
				continue
			
			var local = child.to_local(pos)
			var dist = local.length()
			var pick_radius = child.get_pick_radius()
			
			if dist < pick_radius and dist < best_dist:
				best = child
				best_dist = dist
	
	return best

func _get_mirror_bunker(bunker: Bunker) -> Bunker:
	if bunker.mirror_id == -1:
		return null
	
	for child in editor.get_children():
		if child is Bunker:
			if child.id == bunker.mirror_id:
				return child
	return null

func _deselect_all() -> void:
	if selected_bunker:
		selected_bunker.deselect()
		selected_bunker = null
	mirror_bunker = null
	dragging = false
	is_rotating = false

func _remove_bunker(bunker: Bunker) -> void:
	var mirror = _get_mirror_bunker(bunker)
	if mirror:
		mirror.queue_free()
	bunker.queue_free()
	selected_bunker = null
	mirror_bunker = null
	dragging = false
	is_rotating = false
	print("🗑️ Бункер и его зеркало удалены")
