# StreamerRPG

RPG satírico por turnos ambientado en un mundo post-apocalíptico donde la humanidad
colapsó por volverse obsesiva con la creación de contenido. Crítica al mundo del streaming.

## Equipo
- **Nico** — código (Godot / GDScript)
- **Compañero** — arte y diseño

## Stack
- **Motor:** Godot 4.x
- **Lenguaje:** GDScript
- **Estilo visual:** 2.5D con sprites 2D (por definir el pipeline de arte)
- **Control de versiones:** Git

## Estructura de carpetas
```
assets/        Sprites, tilesets, audio, UI, fuentes (lo que produce arte)
scenes/        Escenas .tscn de Godot (se arman en el editor)
scripts/       Lógica en GDScript
  combat/        Sistema de combate por turnos (ATB "Buffering")
  crafting/      Sistema de crafteo híbrido
  entities/      Personajes, enemigos, jefes
  systems/       Guardado, inventario, diálogos, etc.
  ui/            Lógica de interfaz
resources/     Recursos custom (.tres): personajes, ítems, recetas, estados
data/          Datos del juego (tablas, csv, json)
docs/          Documentos de diseño y plan de desarrollo
```

## Estado
Fase 0 — Cimientos. Estructura del proyecto montada.
Ver `docs/PLAN.md` para el roadmap completo.
