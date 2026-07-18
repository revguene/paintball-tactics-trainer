class_name AIFire
extends RefCounted

var _field_editor = null
var _field = null

func setup(field_editor, field) -> void:
	_field_editor = field_editor
	_field = field
	print("✅ AIFire готов")

func aim_at(player: Player, target_pos: Vector2) -> void:
	var direction = target_pos - player.position_metric
	player.rotation = direction.angle()
	_update_player_visual(player)

func shoot(player: Player, target: Player) -> void:
	# Включаем луч
	if not player.fire_enabled:
		player.fire_enabled = true
	
	# Наводимся на цель
	aim_at(player, target.position_metric)
	
	# В реальной игре здесь будет проверка поражения
	print("   💥 AI игрок ", player.number, " выстрелил в ", target.number)

func _update_player_visual(player: Player) -> void:
	if not _field_editor:
		return
	
	var main = _field_editor.get_tree().current_scene
	if main:
		var player_editor = main.get_node_or_null("PlayerEditor")
		if player_editor:
			for visual in player_editor.players:
				if visual.player == player:
					visual.update_position()
					visual.queue_redraw()
					break
