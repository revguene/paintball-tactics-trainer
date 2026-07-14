class_name PlayerVisual
extends Node2D

var player: Player = null
var selected := false
var radius: float = 12.0
var _field_ref: Field = null
var _editor_ref: FieldEditor = null

var show_ray := false
var ray_length_metric: float = 45.0
var is_editing_ray := false
var is_dragging_handle := false
var drag_start_pos := Vector2.ZERO
var drag_original_length := 0.0

func setup(p_player: Player, field: Field = null, editor: FieldEditor = null) -> void:
	player = p_player
	_field_ref = field
	_editor_ref = editor
	show_ray = false
	ray_length_metric = 45.0
	update_position()
	queue_redraw()

func update_position() -> void:
	if not player:
		return
	
	if _field_ref and _field_ref.calibrated:
		position = player.get_screen_position(_field_ref)
	else:
		position = player.position_metric * 20.0

func is_handle_extended() -> bool:
	return show_ray

func _get_bunkers() -> Array:
	var result = []
	if not _editor_ref:
		return result
	
	for child in _editor_ref.get_children():
		if child is Bunker:
			result.append(child)
	
	return result

func get_ray_color() -> Color:
	if player.team == Player.Team.RED:
		return Color(1.0, 1.0, 0.0, 0.9)
	else:
		return Color(0.2, 0.6, 1.0, 0.9)

func _draw():
	if not player:
		return
	
	var color = Color(0.9, 0.1, 0.1, 1.0) if player.team == Player.Team.RED else Color(0.1, 0.3, 0.9, 1.0)
	
	if player.status == Player.Status.ELIMINATED:
		color = color.darkened(0.5)
	
	# === КРУГ ИГРОКА ===
	draw_circle(Vector2.ZERO, radius, color)
	draw_circle(Vector2.ZERO, radius, color.darkened(0.2), false, 1.5)
	
	if player.number > 0:
		draw_string(
			ThemeDB.fallback_font,
			Vector2(-4, 5),
			str(player.number),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			12,
			Color(1.0, 1.0, 1.0, 0.9)
		)
	
	# === НАПРАВЛЕНИЕ (дуло) ===
	var dir = Vector2(1, 0).rotated(player.rotation)
	var end_pos = dir * (radius * 1.8)
	draw_circle(end_pos, 4.0, Color(1.0, 0.3, 0.3, 1.0))
	
	# === ЛУЧ ===
	if show_ray:
		var direction = Vector2(1, 0).rotated(player.rotation)
		var origin_metric = player.position_metric
		
		# Смещение точки выхода
		var offset_local = player.get_ray_offset(radius)
		var offset_rotated = offset_local.rotated(player.rotation)
		
		# Точка выхода луча в метрах
		var origin_metric_offset = origin_metric + _field_ref.screen_to_field(offset_rotated + position) - origin_metric
		# Упрощенно: переводим смещение в метры
		var offset_metric = Vector2(
			offset_rotated.x / 20.0,
			offset_rotated.y / 20.0
		)
		var ray_origin_metric = origin_metric + offset_metric
		
		var bunkers = _get_bunkers()
		
		# Каст луча от ТОЧКИ ВЫХОДА
		var max_ray_end = RayCaster.cast(ray_origin_metric, direction, bunkers, _field_ref)
		var max_length = ray_origin_metric.distance_to(max_ray_end)
		
		var current_length = min(ray_length_metric, max_length)
		var ray_end_metric = ray_origin_metric + direction * current_length
		var ray_end_px = _field_ref.field_to_screen(ray_end_metric)
		
		# Начало луча в пикселях (смещенная позиция)
		var local_start = offset_rotated
		var local_end = ray_end_px - position
		
		if local_end.length() > 5:
			var ray_color = get_ray_color()
			draw_line(local_start, local_end, ray_color, 2.5)
			
			var num_dots = 5
			for i in range(1, num_dots):
				var t = i / float(num_dots)
				var dot_pos = local_start + (local_end - local_start) * t
				draw_circle(dot_pos, 2.0, ray_color, 0.5)
			
			# Проверка попадания в бункер (от точки выхода)
			var hit_bunker = false
			for bunker in bunkers:
				if bunker is Bunker:
					var hit_dist = bunker.intersects_ray(ray_origin_metric, direction, 100.0)
					if hit_dist < 100.0 and hit_dist < current_length + 0.5:
						hit_bunker = true
						break
			
			if hit_bunker:
				draw_circle(local_end, 6.0, Color(1.0, 0.0, 0.0, 0.9))
				var cross = 8.0
				var perp = Vector2(-dir.y, dir.x)
				draw_line(local_end - dir * cross, local_end + dir * cross, Color(1.0, 0.0, 0.0, 0.6), 1.5)
				draw_line(local_end - perp * cross, local_end + perp * cross, Color(1.0, 0.0, 0.0, 0.6), 1.5)
			else:
				draw_circle(local_end, 5.0, Color(1.0, 0.5, 0.0, 0.8))
			
			if is_editing_ray:
				draw_circle(local_end, 10.0, Color(0.0, 0.8, 1.0, 0.6))
				draw_circle(local_end, 10.0, Color(0.0, 0.5, 1.0, 0.9), false, 2.0)
				draw_string(
					ThemeDB.fallback_font,
					local_end + Vector2(12, -8),
					"↕",
					HORIZONTAL_ALIGNMENT_LEFT,
					-1,
					16,
					Color(0.0, 0.8, 1.0, 0.8)
				)
		
		# Точка выхода луча (визуальная подсказка)
		if selected:
			var dot_color = Color(0.0, 1.0, 0.0, 0.8)
			match player.ray_origin:
				Player.RayOrigin.LEFT:
					dot_color = Color(1.0, 0.5, 0.0, 0.8)
				Player.RayOrigin.RIGHT:
					dot_color = Color(0.0, 0.5, 1.0, 0.8)
				_:
					dot_color = Color(0.0, 1.0, 0.0, 0.8)
			
			draw_circle(offset_rotated, 4.0, dot_color)
			draw_string(
				ThemeDB.fallback_font,
				offset_rotated + Vector2(8, -4),
				player.get_ray_origin_name(),
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				8,
				Color(0.8, 0.8, 0.8, 0.6)
			)
	
	if selected:
		draw_circle(Vector2.ZERO, radius + 4, Color(1.0, 0.8, 0.0, 0.4), false, 2.0)
		draw_arc(Vector2.ZERO, radius + 8, 0, TAU, 32, Color(1.0, 0.8, 0.0, 0.2), 1.0)

func get_ray_end_pixel() -> Vector2:
	if not show_ray or not _field_ref:
		return position
	
	var origin_metric = player.position_metric
	var direction = Vector2(1, 0).rotated(player.rotation)
	
	# Смещение точки выхода
	var offset_local = player.get_ray_offset(radius)
	var offset_rotated = offset_local.rotated(player.rotation)
	var offset_metric = Vector2(offset_rotated.x / 20.0, offset_rotated.y / 20.0)
	var ray_origin_metric = origin_metric + offset_metric
	
	var bunkers = _get_bunkers()
	
	var max_ray_end = RayCaster.cast(ray_origin_metric, direction, bunkers, _field_ref)
	var max_length = ray_origin_metric.distance_to(max_ray_end)
	var current_length = min(ray_length_metric, max_length)
	var ray_end_metric = ray_origin_metric + direction * current_length
	
	return _field_ref.field_to_screen(ray_end_metric)

func is_over_ray_handle(mouse_pos: Vector2) -> bool:
	if not show_ray or not is_editing_ray:
		return false
	
	var handle_pos = get_ray_end_pixel()
	return handle_pos.distance_to(mouse_pos) < 20.0

func start_editing() -> void:
	is_editing_ray = true
	is_dragging_handle = false
	queue_redraw()

func stop_editing() -> void:
	is_editing_ray = false
	is_dragging_handle = false
	queue_redraw()

func update_ray_length(mouse_pos: Vector2) -> void:
	if not is_dragging_handle or not _field_ref:
		return
	
	var origin_metric = player.position_metric
	var direction = Vector2(1, 0).rotated(player.rotation)
	
	var offset_local = player.get_ray_offset(radius)
	var offset_rotated = offset_local.rotated(player.rotation)
	var offset_metric = Vector2(offset_rotated.x / 20.0, offset_rotated.y / 20.0)
	var ray_origin_metric = origin_metric + offset_metric
	
	var bunkers = _get_bunkers()
	
	var max_ray_end = RayCaster.cast(ray_origin_metric, direction, bunkers, _field_ref)
	var max_length = ray_origin_metric.distance_to(max_ray_end)
	
	var mouse_metric = _field_ref.screen_to_field(mouse_pos)
	var to_mouse = mouse_metric - ray_origin_metric
	var new_length = to_mouse.dot(direction)
	
	new_length = clamp(new_length, 0.5, max_length)
	ray_length_metric = new_length
	
	queue_redraw()

func enable_ray() -> void:
	show_ray = true
	queue_redraw()

func disable_ray() -> void:
	show_ray = false
	is_editing_ray = false
	is_dragging_handle = false
	queue_redraw()

func select():
	selected = true
	queue_redraw()

func deselect():
	selected = false
	is_editing_ray = false
	is_dragging_handle = false
	queue_redraw()
