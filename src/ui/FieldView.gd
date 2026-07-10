class_name FieldView
extends Node2D

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

func set_image(texture: Texture2D) -> void:
	_image_texture = texture
	_image_sprite.texture = texture
	# Устанавливаем масштаб 1:1
	_image_sprite.scale = Vector2(1, 1)
	image_set.emit(texture)

func clear_image() -> void:
	_image_texture = null
	_image_sprite.texture = null
	image_cleared.emit()

func get_image_size() -> Vector2:
	if _image_texture:
		return Vector2(_image_texture.get_width(), _image_texture.get_height())
	return Vector2.ZERO

func has_image() -> bool:
	return _image_texture != null

# Новый метод для масштабирования спрайта
func set_sprite_scale(scale: Vector2) -> void:
	if _image_sprite:
		_image_sprite.scale = scale
