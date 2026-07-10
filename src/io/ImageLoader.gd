class_name ImageLoader
extends RefCounted


static func load_texture(path: String) -> Texture2D:
	if path.is_empty():
		push_error("Image path is empty.")
		return null

	if not FileAccess.file_exists(path):
		push_error("Image not found: %s" % path)
		return null

	var image := Image.new()
	var err := image.load(path)

	if err != OK:
		push_error("Cannot load image: %s" % path)
		return null

	return ImageTexture.create_from_image(image)
