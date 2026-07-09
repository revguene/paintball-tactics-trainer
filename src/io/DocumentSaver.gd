extends RefCounted

## Сохранение документов в .ptf

signal save_completed(path: String)
signal save_failed(path: String, error: String)

## Сохранить документ в файл
func save_document(document: Document, path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		save_failed.emit(path, "Не удалось создать файл")
		return
	
	var data = document.to_dict()
	var json_string = JSON.stringify(data, "\t")
	
	file.store_string(json_string)
	file.close()
	
	save_completed.emit(path)
	print("Документ сохранён: %s" % path)
