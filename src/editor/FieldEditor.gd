class_name FieldEditor
extends Node2D

enum Tool {
	SELECT,
	ADD_BUNKER,
	ADD_PLAYER,
	DRAW_LINE,
	SPAWN_TEAMS
}

var current_tool: Tool = Tool.SELECT
var tools: Dictionary = {}

const SelectToolClass = preload("res://src/editor/tools/SelectTool.gd")
const AddBunkerToolClass = preload("res://src/editor/tools/AddBunkerTool.gd")

var player_tool: BaseTool = null
var _team_menu: TeamMenu = null

func _ready() -> void:
	tools[Tool.SELECT] = SelectToolClass.new(self)
	tools[Tool.ADD_BUNKER] = AddBunkerToolClass.new(self)
	
	player_tool = PlayerTool.new(self)
	
	call_deferred("_setup_team_menu")
	
	_set_tool(Tool.SELECT)
	print("FieldEditor готов, инструмент: SELECT")

func _setup_team_menu() -> void:
	_team_menu = TeamMenu.new()
	var main = get_tree().current_scene
	if main:
		var field = main.get_field() if main.has_method("get_field") else null
		var player_editor = main.get_node_or_null("PlayerEditor")
		if field and player_editor:
			_team_menu.setup(field, player_editor, main)
		else:
			print("⚠️ TeamMenu: field или player_editor не найдены")
	add_child(_team_menu)

func _set_tool(tool: Tool) -> void:
	current_tool = tool
	var tool_name = ""
	match tool:
		Tool.SELECT:
			tool_name = "SELECT"
		Tool.ADD_BUNKER:
			tool_name = "ADD_BUNKER"
		Tool.ADD_PLAYER:
			tool_name = "ADD_PLAYER"
		Tool.DRAW_LINE:
			tool_name = "DRAW_LINE"
		Tool.SPAWN_TEAMS:
			tool_name = "SPAWN_TEAMS"
	print("🔧 Инструмент: %s" % tool_name)

func set_tool(tool_name: String) -> void:
	match tool_name:
		"Select":
			_set_tool(Tool.SELECT)
		"AddBunker":
			_set_tool(Tool.ADD_BUNKER)
		"AddPlayer":
			_set_tool(Tool.ADD_PLAYER)
		"SpawnTeams":
			_set_tool(Tool.SPAWN_TEAMS)
		_:
			print("❌ Неизвестный инструмент: %s" % tool_name)

func _unhandled_input(event: InputEvent) -> void:
	var main = get_tree().current_scene
	if main and main.has_method("is_calibrated"):
		if not main.is_calibrated():
			return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_set_tool(Tool.SELECT)
				get_viewport().set_input_as_handled()
			KEY_2:
				_set_tool(Tool.ADD_BUNKER)
				get_viewport().set_input_as_handled()
			KEY_3:
				_set_tool(Tool.ADD_PLAYER)
				get_viewport().set_input_as_handled()
			KEY_4:
				_set_tool(Tool.SPAWN_TEAMS)
				_show_team_menu()
				get_viewport().set_input_as_handled()
	
	if current_tool == Tool.ADD_PLAYER and player_tool:
		player_tool._input(event)
	elif current_tool in tools:
		tools[current_tool]._input(event)

func _show_team_menu() -> void:
	if _team_menu:
		var main = get_tree().current_scene
		if main and main.has_method("get_field"):
			var field = main.get_field()
			var player_editor = main.get_node_or_null("PlayerEditor")
			if field and player_editor:
				_team_menu.setup(field, player_editor, main)
		
		var mouse_pos = get_global_mouse_position()
		_team_menu.show_menu(mouse_pos)
	else:
		print("❌ TeamMenu не создан!")

func get_field() -> Field:
	var main = get_tree().current_scene
	if main and main.has_method("get_field"):
		return main.get_field()
	return null

func get_player_editor() -> PlayerEditor:
	var main = get_tree().current_scene
	if main:
		return main.get_node_or_null("PlayerEditor")
	return null
