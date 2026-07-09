extends Node2D
class_name FieldView

## Отображение поля с изображением

signal image_set(texture: Texture2D)
signal image_cleared()

var _image_texture: Texture2D = null
var _image_sprite: Sprite2D = null

func _ready() -> void:
	_setup_sprite()

func _setup_sprite() -> void:
	_image_sprite = Sprite2D.new()
	_image_sprite.centered = false
	add_child(_image_sprite)

## Установить изображение
func set_image(texture: Texture2D) -> void:
	_image_texture = texture
	_image_sprite.texture = texture
	image_set.emit(texture)

## Очистить изображение
func clear_image() -> void:
	_image_texture = null
	_image_sprite.texture = null
	image_cleared.emit()

## Получить размер изображения
func get_image_size() -> Vector2:
	if _image_texture:
		return Vector2(_image_texture.get_width(), _image_texture.get_height())
	return Vector2.ZERO

## Есть ли изображение
func has_image() -> bool:
	return _image_texture != null
