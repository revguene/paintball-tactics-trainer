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
const PlayerToolClass = preload("res://src/editor/tools/PlayerTool.gd")

func _ready() -> void:
	tools[Tool.SELECT] = SelectToolClass.new(self)
	tools[Tool.ADD_BUNKER] = AddBunkerToolClass.new(self)
	tools[Tool.ADD_PLAYER] = PlayerToolClass.new(self)
	
	_set_tool(Tool.SELECT)
	print("FieldEditor готов, инструмент: SELECT")

func _set_tool(tool: Tool) -> void:
	current_tool = tool
	print("🔧 Инструмент: %s" % tool)

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
	# Проверяем, откалибровано ли поле
	var main = get_tree().current_scene
	if main and main.has_method("is_calibrated"):
		if not main.is_calibrated():
			return  # Игнорируем все действия, пока поле не откалибровано
	
	if current_tool in tools:
		tools[current_tool]._input(event)
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_set_tool(Tool.SELECT)
			KEY_2:
				_set_tool(Tool.ADD_BUNKER)
			KEY_3:
				_set_tool(Tool.ADD_PLAYER)
			KEY_4:
				_set_tool(Tool.DRAW_LINE)

func get_field() -> Field:
	var main = get_tree().current_scene
	if main and main.has_method("get_field"):
		return main.get_field()
	return null
