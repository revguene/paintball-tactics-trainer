# Architecture

## Основные сущности
- Layout (Макет поля)
- Bunker (Укрытие)
- Player (Игрок)
- Scenario (Сценарий)
- Ray (Луч)
- Sector (Сектор)
- Camera (Камера)
- Editor (Редактор)

## Структура src/
- core/ - базовые классы и утилиты
- editor/ - логика редактора
- ui/ - UI компоненты
- import/ - импорт данных
- geometry/ - геометрические расчёты
- scenario/ - сценарии
- io/ - сохранение и загрузка

## Паттерны
- Observer (Сигналы Godot)
- Factory
- Singleton
- MVC
