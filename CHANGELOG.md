# Changelog

Все значимые изменения в проекте будут записываться в этом файле.

Формат основан на [Keep a Changelog](https://keepachangelog.com/ru/1.0.0/).

---

## [0.1.0] - 2026-07-09

### Добавлено (Added)
- Структура проекта (Sprint 0)
- AI/ документация (6 файлов)
- DATA_MODEL.md
- Классы: Document, Camera, Layer, Entity, Token
- Главная сцена Main.tscn

### Изменено (Changed)
- scripts/ переименован в src/
- assets/ реструктурирован

### Исправлено (Fixed)
- Дубликаты в DATA_MODEL.md

---

## [Не выпущено] - Sprint 1

### Планируется
- ImageLoader
- Сохранение .ptf
- Панель слоёв
- Главное меню

## [0.1.0] - 2026-07-09

### Sprint 1 — Infrastructure & Core Classes — ✅ ПРИНЯТ

- Core: Document, Camera, Layer, Entity, Token
- ADR-0001: Entity-Token Model
- ADR-0002: Layer System
- ADR-0003: Undo/Redo postponed to Sprint 6
- ADR-0004: Images stored separately from .ptf
- ADR-0005: Project-Document Structure
- Architecture declared stable
