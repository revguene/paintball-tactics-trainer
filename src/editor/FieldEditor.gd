class_name FieldEditor
extends Node2D

enum Tool {
	SELECT,
	ADD_BUNKER,
	ADD_PLAYER,
	DRAW_LINE
}

var current_tool: Tool = Tool.SELECT
var tools: Dictionary = {}

const SelectToolClass = preload("res://src/editor/tools/SelectTool.gd")
const AddBunkerToolClass = preload("res://src/editor/tools/AddBunkerTool.gd")

# Добавляем PlayerTool
var player_tool: BaseTool = null

func _ready() -> void:
	tools[Tool.SELECT] = SelectToolClass.new(self)
	tools[Tool.ADD_BUNKER] = AddBunkerToolClass.new(self)
	
	# Создаём PlayerTool
	player_tool = PlayerTool.new(self)
	
	_set_tool(Tool.SELECT)
	print("FieldEditor готов, инструмент: SELECT")

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
	print("🔧 Инструмент: %s" % tool_name)

func set_tool(tool_name: String) -> void:
	match tool_name:
		"Select":
			_set_tool(Tool.SELECT)
		"AddBunker":
			_set_tool(Tool.ADD_BUNKER)
		"AddPlayer":
			_set_tool(Tool.ADD_PLAYER)
		_:
			print("❌ Неизвестный инструмент: %s" % tool_name)

func _unhandled_input(event: InputEvent) -> void:
	# === TAB обрабатывается в PlayerEditor - игнорируем здесь ===
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		var player_editor = get_player_editor()
		if player_editor and player_editor.selected_player:
			player_editor._input(event)
			get_viewport().set_input_as_handled()
			return
		# Если игрок не выделен - игнорируем TAB
		get_viewport().set_input_as_handled()
		return
		return
	
	# Проверяем, откалибровано ли поле
	var main = get_tree().current_scene
	if main and main.has_method("is_calibrated"):
		if not main.is_calibrated():
			return
	
	# Обработка горячих клавиш
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
				_set_tool(Tool.DRAW_LINE)
				get_viewport().set_input_as_handled()
	
	# Передаём событие текущему инструменту
	if current_tool == Tool.ADD_PLAYER and player_tool:
		player_tool._input(event)
	elif current_tool in tools:
		tools[current_tool]._input(event)

func get_field() -> Field:
	var main = get_tree().current_scene
	if main and main.has_method("get_field"):
		return main.get_field()
	return null

# Метод для PlayerTool
func get_player_editor() -> PlayerEditor:
	var main = get_tree().current_scene
	if main:
		return main.get_node_or_null("PlayerEditor")
	return null
