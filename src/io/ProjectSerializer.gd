class_name ProjectSerializer
extends RefCounted


static func save_document(document: Document, path: String) -> Error:
	var json_string := JSON.stringify(document.to_dictionary(), "\t")

	var file := FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		return FileAccess.get_open_error()

	file.store_string(json_string)
	file.close()

	document.clear_modified()

	return OK


static func load_document(path: String) -> Document:

	if not FileAccess.file_exists(path):
		return null

	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		return null

	var text := file.get_as_text()
	file.close()

	var json := JSON.new()

	if json.parse(text) != OK:
		return null

	var document := Document.new()
	document.from_dictionary(json.data)

	return document
