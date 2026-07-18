class_name WinCondition
extends RefCounted

var _player_editor = null

func setup(player_editor) -> void:
	_player_editor = player_editor
	print("✅ WinCondition готов")

func check_win() -> bool:
	var red_alive = 0
	var blue_alive = 0
	
	if not _player_editor:
		return false
	
	for visual in _player_editor.players:
		if not visual.player:
			continue
		
		if visual.player.status == Player.Status.ELIMINATED:
			continue
		
		if visual.player.team == Player.Team.RED:
			red_alive += 1
		else:
			blue_alive += 1
	
	if red_alive == 0:
		_winner = "BLUE"
		return true
	
	if blue_alive == 0:
		_winner = "RED"
		return true
	
	return false

func get_winner() -> String:
	return _winner

var _winner: String = ""
