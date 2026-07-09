# Paintball Tactics Trainer

## Sprint 0 — Foundation

You are a Senior Software Architect and Senior Godot 4 Developer.

Your task is NOT to create a game.

Your task is to create the foundation for a tactical editor for tournament paintball.

The application must be modular.

The application must be written in Godot 4.

Language: GDScript.

Architecture must support future AI, multiplayer and replay system.

------------------------------------------------------------

PROJECT GOAL

Create an editor where users can:

- load a 2D field image
- zoom
- pan
- later place bunkers
- later place players
- later draw shooting lines

No game rules.

No AI.

No networking.

------------------------------------------------------------

Create the following folder structure.

paintball-tactics-trainer/

    .github/

        ISSUE_TEMPLATE/

        workflows/

    .cursor/

        rules/

    assets/

        bunkers/

        icons/

        layouts/

        ui/

    data/

        bunkers/

        layouts/

        scenarios/

    docs/

    scenes/

    scripts/

        core/

        editor/

        import/

        ui/

    tests/

------------------------------------------------------------

Create documentation.

README.md

Vision.md

Architecture.md

Rules.md

Roadmap.md

PROJECT_PRINCIPLES.md

------------------------------------------------------------

README

Describe the project.

Explain installation.

Explain roadmap.

------------------------------------------------------------

Vision

Explain that this project is NOT a paintball game.

It is a tactical spatial thinking trainer.

------------------------------------------------------------

Architecture

Describe all future entities.

Layout

Bunker

Player

Scenario

Ray

Sector

Camera

Editor

------------------------------------------------------------

Rules

Leave empty.

Only create sections.

------------------------------------------------------------

Roadmap

Sprint 0

Foundation

Sprint 1

Image import

Sprint 2

Bunker editor

Sprint 3

Player editor

Sprint 4

Ray editor

Sprint 5

Movement

Sprint 6

Scenario editor

Sprint 7

Rule engine

Sprint 8

Replay

Sprint 9

AI

------------------------------------------------------------

PROJECT PRINCIPLES

Write the following principles.

The application must never make tactical decisions for the player.

The application visualizes tactical situations.

All gameplay logic must be data-driven.

Everything must be configurable.

No hardcoded field layouts.

Every field must be loaded dynamically.

Everything should be modular.

------------------------------------------------------------

Create Godot project.

Create main scene.

Main window.

Menu bar.

Toolbar.

Empty viewport.

Status bar.

------------------------------------------------------------

Main menu

File

New

Open Field

Save

Exit

------------------------------------------------------------

Create empty Camera2D.

Support

Zoom

Pan

------------------------------------------------------------

Do not implement gameplay.

Do not implement AI.

Do not implement players.

Do not implement bunkers.

Only foundation.

------------------------------------------------------------

Expected result

Application launches.

Main window opens.

Project architecture is ready.

Documentation exists.

Ready for Sprint 1.

## Обновлённая структура (Sprint 0)

Вместо scripts/ используется src/ с модулями:

- src/core/     — базовые классы и утилиты
- src/editor/   — логика редактора
- src/ui/       — UI компоненты
- src/import/   — импорт данных
- src/geometry/ — геометрические расчёты
- src/scenario/ — сценарии
- src/io/       — ввод/вывод, сохранение

Assets переструктурированы:

- assets/images/layouts/   — изображения полей
- assets/images/bunkers/   — иконки укрытий
- assets/images/ui/        — UI элементы

Данные хранятся отдельно:

- data/layouts/   — JSON с макетами полей
- data/bunkers/   — JSON с данными укрытий
- data/scenarios/ — JSON со сценариями
