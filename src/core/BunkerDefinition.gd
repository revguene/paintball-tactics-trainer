class_name BunkerDefinition
extends Resource

@export var id: String = ""
@export var display_name: String = ""

# Размеры основания в метрах
@export var width: float = 1.0
@export var depth: float = 1.0

# Форма (полигон для отрисовки)
@export var shape: PackedVector2Array = PackedVector2Array()

# SVG или PNG иконка
@export var icon_path: String = ""

# Разрешено ли зеркалирование
@export var mirrorable := true

# Цвет (для отрисовки)
@export var color: Color = Color.WHITE
