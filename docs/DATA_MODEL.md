# Data Model — Paintball Tactical Editor

## Архитектурная парадигма

Проект строится как **CAD-система** для тактического анализа пейнтбола.
Workspace
└── Document (.ptf)
├── Image (Layout)
├── Geometry
│ ├── Bunkers
│ ├── Sectors
│ └── Measurements
├── Layers (как в Photoshop)
│ ├── Field Image (всегда внизу)
│ ├── Geometry (бункеры)
│ ├── Players (позиции игроков)
│ ├── Rays (линии стрельбы)
│ ├── Movement (траектории)
│ ├── Control (зоны контроля)
│ └── Comments (заметки)
├── Camera (View)
└── Metadata

## Ключевые сущности

### Workspace
Рабочее пространство пользователя. Может содержать несколько документов.
- `id` — уникальный идентификатор
- `name` — название
- `documents` — список открытых документов
- `active_document` — текущий активный документ

### Document (.ptf)
Главный файл проекта. Содержит всё состояние редактора.
- `version` — версия формата
- `image` — ссылка на изображение поля
- `geometry` — геометрия поля (бункеры, сектора)
- `layers` — список слоёв
- `camera` — состояние камеры
- `metadata` — автор, дата, описание

### Layer (Слой)
Как в Photoshop. Можно включать/выключать видимость.
- `name` — название слоя
- `visible` — видимость (☑/☐)
- `locked` — защита от редактирования
- `opacity` — прозрачность (0.0-1.0)
- `objects` — список объектов на слое

**Стандартные слои:**
1. **Image** — изображение поля (всегда внизу, заблокирован)
2. **Geometry** — бункеры и статические объекты
3. **Players** — позиции игроков (Token)
4. **Rays** — линии стрельбы
5. **Movement** — траектории перемещения
6. **Control** — зоны контроля
7. **Comments** — заметки и аннотации

### Entity
Базовый класс для всех объектов на поле.
- `id` — уникальный идентификатор (UUID)
- `type` — тип объекта
- `position` — позиция (Vector2)
- `rotation` — поворот
- `scale` — масштаб
- `properties` — словарь дополнительных свойств

### Token (вместо Player)
Токен — базовый элемент, который может быть:
- **Player** — игрок
- **Referee** — судья
- **Camera** — камера
- **Marker** — маркер точки
- **Direction** — направление

### Bunker (наследуется от Entity)
- `bunker_type` — тип (snake, dorito, aztec, carwash, temple)
- `size` — размеры (width, height)
- `orientation` — ориентация (0-360)

### Ray (Луч/Линия стрельбы)
- `from` — ID источника (Token)
- `to` — ID цели (Token)
- `type` — тип (direct/blocked/possible)
- `color` — цвет линии
- `layer` — слой, на котором находится

### Sector (Сектор контроля)
- `points` — массив точек (полигон)
- `team` — команда, контролирующая сектор
- `priority` — приоритет (1-5)
- `color` — цвет заливки

### Camera
- `position` — позиция (Vector2)
- `zoom` — уровень зума
- `min_zoom` — минимальный зум
- `max_zoom` — максимальный зум
- `bounds` — границы движения (Rect2)

## Модули src/
src/
├── core/ # Математика, модель данных, базовые классы
├── editor/ # Инструменты редактирования
├── ui/ # UI компоненты (меню, тулбар, панели)
├── import/ # Импорт изображений и данных
├── geometry/ # Полигоны, лучи, коллизии, координаты
├── scenario/ # Сценарии, временная шкала, документы
└── io/ # Сохранение, загрузка, экспорт (.ptf)

## Формат файла (.ptf)

```json
{
  "version": "1.0",
  "workspace": {
    "name": "RXL_Moscow_2025_Analysis",
    "author": "revguene",
    "created": "2026-07-09",
    "modified": "2026-07-09"
  },
  "image": {
    "path": "assets/images/layouts/rxl_moscow_2025.png",
    "width": 1920,
    "height": 1080,
    "scale": 1.0
  },
  "geometry": {
    "bunkers": [],
    "sectors": [],
    "measurements": []
  },
  "layers": [
    {
      "id": "layer_image",
      "name": "Image",
      "visible": true,
      "locked": true,
      "opacity": 1.0,
      "type": "image"
    },
    {
      "id": "layer_geometry",
      "name": "Geometry",
      "visible": true,
      "locked": false,
      "opacity": 1.0,
      "type": "geometry"
    },
    {
      "id": "layer_players",
      "name": "Players",
      "visible": true,
      "locked": false,
      "opacity": 1.0,
      "type": "tokens"
    },
    {
      "id": "layer_rays",
      "name": "Rays",
      "visible": true,
      "locked": false,
      "opacity": 0.8,
      "type": "rays"
    }
  ],
  "camera": {
    "position": [960, 540],
    "zoom": 1.0,
    "bounds": [0, 0, 1920, 1080]
  }
}
