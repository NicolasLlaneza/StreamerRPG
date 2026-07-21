# Plan de Desarrollo — StreamerRPG

> Equipo: Nico (código) + compañero (arte/diseño), posible 3° integrante (audio/guión).
> Motor: Godot 4.7 · GDScript · 2.5D con sprites 2D.
> Objetivo: aprender → terminar → comercializar como etapa final (condicional).
> Los plazos son estimaciones para calibrar expectativas, no un contrato.

## Principio rector

**Nunca construir contenido de un sistema que todavía no probamos que es divertido.**
Primero el núcleo con lo mínimo; producción en masa recién cuando está validado.

---

## Fase 0 — Cimientos ✅ (casi completa)

- [x] Repo Git + GitHub (https://github.com/NicolasLlaneza/StreamerRPG)
- [x] Estructura de carpetas del proyecto Godot
- [x] Skills de tooling (godot-gdscript-patterns, godot-ui)
- [x] Prototipo de combate ATB "Buffering" funcionando
- [ ] **Pipeline de arte** (compañero): elegir pixel art vs dibujado, paleta,
      resolución de sprites, y producir UN personaje animado de prueba.
      *Es la decisión que desbloquea todo el trabajo de arte.*

## Fase 1 — Vertical Slice ⭐ (en curso) — LA FASE MÁS IMPORTANTE

Objetivo: rebanada jugable de ~15 min que demuestre que el juego es divertido y gracioso.

1. [x] Combate ATB + turno del jugador + habilidades (Mate/Bomba) + estados (Hype/Lag)
2. [ ] **Graduar a escenas** (`CombatantView.tscn`) ← *paso actual*
3. [ ] Party de 3 + selección de objetivo + **cola de turnos visible**
4. [ ] Recurso de habilidades (medidor **"Señal"**) + los 5 estados completos
5. [ ] Crafting mínimo: 5-6 recetas (2 fallidas) con UI tosca
6. [ ] Dungeon de 3-4 salas + 1 jefe arquetipo (candidato: **el Tóxico de Esports** —
       castiga con Muteado/Cancelado, se auto-Hypea, arquetipo reconocible)
7. [ ] **GATE: test con 3-5 personas ajenas.** ¿Se ríen? ¿Entienden el crafting?
       ¿Repetirían? Si no → ajustar diseño ANTES de producir contenido.

## Fase 2 — Sistemas completos

- [ ] Sistema de diálogos (evaluar addon **Dialogue Manager**)
- [ ] Guardado (puntos temáticos: router wifi + autosave pre-jefe)
- [ ] Inventario y equipamiento (2-3 slots, alimentado por crafting)
- [ ] Crafting híbrido completo (tipos de material + todas las recetas)
- [ ] Rotación de party (6 compañeros, banca gana XP) + mascota Frappe en exploración
- [ ] XP/niveles simplificado (la personalización vive en el crafting)
- [ ] Dificultad: Modo Historia / Normal

## Fase 3 — Contenido (la fase larga)

- [ ] **Guión completo** — ⚠️ empieza a escribirse YA, en paralelo, en docs/
- [ ] Mapa/hub + coleccionables-lore (clips virales, merch, memes fósiles)
- [ ] 5-7 dungeons con jefes-arquetipo
- [ ] Enemigos + loot + bestiario con descripciones graciosas
- [ ] 5-8 quests secundarias (cada una un sketch)
- [ ] Arte final reemplazando placeholders
- [ ] Música y sonido

## Fase 4 — Pulido

- [ ] Balance, game feel, tutoriales, bugs
- [ ] Logros (incluido "Museo del Fracaso" de recetas fallidas)
- [ ] Playtesting amplio vía itch.io (página privada)

## Fase 5 — Comercialización (condicional al éxito del slice)

- [ ] Página de Steam TEMPRANA (wishlists se acumulan meses; abrir cuando haya trailer digno)
- [ ] Demo pública / Next Fest
- [ ] Prensa + streamers (que son el público Y el tema: marketing que se escribe solo)

---

## Reparto permanente

| Nico + Claude (código) | Compañero (arte/diseño) |
|---|---|
| Arquitectura, combate, crafting, estados | Sprites (personajes/enemigos/jefes) |
| IA, UI-lógica, guardado, integración | Tilesets, ítems, iconos, retratos |
| | Co-diseño del guión |

## Riesgos en el radar

1. **Scope**: 5-6h es ambicioso para el equipo. El vertical slice permite recortar con datos.
2. **El arte es el cuello de botella**, no el código.
3. **El guión es un proyecto paralelo** — arrancar ya.
4. **Burnout**: cada fase termina en algo jugable y mostrable. Celebrar checkpoints.

Ver `ANALISIS.md` para el análisis completo de diseño, sistemas y herramientas.
