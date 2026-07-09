extends RefCounted

## Загрузка документов из .ptf

signal load_completed(document: Document, path: String)
signal load_failed(path: String, error: String)

## Загрузить документ из файла
func load_document(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		load_failed.emit(path, "Не удалось открыть файл")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_error = json.parse(json_string)
	
	if parse_error != OK:
		load_failed.emit(path, "Ошибка парсинга JSON: %s" % json.get_error_message())
		return
	
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		load_failed.emit(path, "Неверный формат данных")
		return
	
	var document = Document.new()
	document.from_dict(data)
	
	load_completed.emit(document, path)
	print("Документ загружен: %s" % path)
