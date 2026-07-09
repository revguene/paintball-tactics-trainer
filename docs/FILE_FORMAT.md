# PTF File Format Specification

**Версия:** 1.0

**Статус:** Утверждено (Sprint 1)

---

## Общее описание

PTF (Paintball Tactical File) — основной формат документов Paintball Tactical Editor.

Файл хранит данные в формате JSON.

Изображения хранятся отдельно, в файле указывается только путь к ним.

---

## Структура файла

```json
{
  "version": "1.0",
  "uuid": "550e8400-e29b-41d4-a716-446655440000",
  "workspace": {
    "name": "RXL_Moscow_2025_Analysis",
    "author": "revguene",
    "created": "2026-07-09T23:00:00",
    "modified": "2026-07-09T23:00:00"
  },
  "image": {
    "path": "images/field.png",
    "width": 1920,
    "height": 1080,
    "scale": 1.0
  },
  "layers": [
    {
      "id": "layer_image",
      "name": "Image",
      "type": "image",
      "visible": true,
      "locked": true,
      "opacity": 1.0
    }
  ],
  "camera": {
    "position": [960, 540],
    "zoom": 1.0,
    "bounds": [0, 0, 1920, 1080]
  },
  "metadata": {
    "description": "Тактический анализ финала",
    "tags": ["tournament", "final", "analysis"]
  }
}
