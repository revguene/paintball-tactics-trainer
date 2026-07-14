class_name ProjectSerializer
extends RefCounted

static func save_document(document: Document, path: String) -> Error:
	print("📝 ProjectSerializer.save_document()")
	print("   Путь: %s" % path)
	
	var json_string := JSON.stringify(document.to_dictionary(), "\t")
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		var err = FileAccess.get_open_error()
		print("❌ Ошибка открытия файла: %s" % err)
		return err
	
	file.store_string(json_string)
	file.close()
	
	print("✅ Файл записан: %s" % path)
	return OK

static func load_document(path: String) -> Document:
	print("📂 ProjectSerializer.load_document()")
	print("   Путь: %s" % path)
	
	if not FileAccess.file_exists(path):
		print("❌ Файл не существует: %s" % path)
		return null
	
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("❌ Ошибка открытия файла: %s" % path)
		return null
	
	var text := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	if json.parse(text) != OK:
		print("❌ Ошибка парсинга JSON")
		return null
	
	var document := Document.new()
	document.from_dictionary(json.data)
	print("✅ Документ загружен: %s" % path)
	return document
