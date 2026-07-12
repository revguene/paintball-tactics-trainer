class_name BaseTool
extends RefCounted

var editor: FieldEditor

func _init(p_editor: FieldEditor = null) -> void:
	editor = p_editor

func _input(event: InputEvent) -> void:
	pass

func activate() -> void:
	pass

func deactivate() -> void:
	pass
