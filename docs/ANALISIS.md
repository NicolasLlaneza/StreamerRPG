# Análisis Profesional — StreamerRPG

> Análisis de la idea desde la perspectiva de desarrollo profesional de videojuegos.
> Generado en Fase 0/1 del proyecto. Documento vivo: actualizar cuando cambien decisiones.

## 1. Análisis de la idea

### Fortalezas

**a. Nicho con audiencia incorporada.** La sátira del streaming tiene un público que se
autoidentifica: gente que consume Twitch/YouTube/TikTok y reconoce los códigos. Juegos con
hooks culturales específicos (*Undertale*, *South Park: The Stick of Truth*) demuestran que
el humor reconocible vende más que la mecánica novedosa. Casi nadie hizo "el RPG de la
cultura streamer" en serio: hay una ventana.

**b. Coherencia temática excepcional.** Los estados (Cancelado, Muteado, Lag, Hype,
Desmonetizado) no son estados genéricos con nombre gracioso — son mecánicas que emergen
del tema. Lag = perder el turno es *exactamente* lo que el lag es. Lo mismo el crafting
con recetas fallidas: convierte el fracaso en contenido.

**c. Scope declarado honesto.** 5-6h es un objetivo de indie comercializable real
(*A Short Hike*, *Citizen Sleeper* venden bien en ese rango).

**d. Dispositivo narrativo útil.** "Cree que está soñando" justifica la suerte absurda,
el tono despreocupado y los chistes malos — y regala un arco: el momento en que descubre
que NO es un sueño es el punto de giro del tercer acto.

### Riesgos

**a. El humor referencial caduca.** Riesgo #1 de diseño. Guiños a streamers específicos:
(1) en 2-3 años pueden ser irrelevantes; (2) riesgo legal/PR al parodiar personas reales
identificables en un producto comercial; (3) limita el mercado a quien los conoce.
**Mitigación: arquetipos, no personas.** "El streamer de bañera", "el tóxico de esports",
"el reaccionador" son universales y atemporales. Jefes inspirados *en el estilo* sí;
jefes que *son* el streamer real, no.

**b. Humor localizado = arma de doble filo.** Mate, Fernet, "Metitila", crocs: oro para
LATAM, barrera para el resto. **Decisión tomada como recomendación: abrazar lo argentino.**
Un juego genérico compite con miles; "el RPG argentino de streamers" es único. La identidad
regional fuerte es diferenciador, no defecto (*Yakuza*).

**c. La comedia es el asset más difícil.** El guión necesita tantas horas como el código,
y los chistes se playtestean como las mecánicas.

**d. Riesgo de equipo.** 2-3 personas sin experiencia + 12+ meses = el riesgo real es
burnout/abandono, no fracaso técnico. Mitigación: fases con checkpoints jugables.

## 2. Análisis de jugabilidad

### Core loop
```
Explorar → Recolectar materiales → Craftear → Combatir (dungeon) → Jefe → Historia → repetir
```

**Hallazgo clave: el crafting es el sistema más original y hay que atarlo al loop.**
- Hacer del crafting la **progresión principal** (el equipo crafteado es la fuente de poder;
  los materiales son la razón de explorar). Que el sistema estrella sea obligatorio, no ignorable.
- **Las recetas fallidas necesitan valor** (logro "Museo del Fracaso", NPC que compra fallos,
  fallos que desbloquean diálogos). Si fallar solo castiga, el jugador deja de experimentar.

### Combate ATB "Buffering" (validado en prototipo)
- ATB con modo wait: tensión + espacio para leer los chistes. Correcto.
- Riesgo del ATB con party de 3: turnos agolpados. Mitigación: diferencias de SPD marcadas
  por rol + **cola de turnos visible** (estilo FFX / Child of Light).
- **Falta definir el recurso de habilidades.** Propuesta temática: medidor de **"Señal"**
  que se carga con ataques básicos y se gasta en habilidades (modelo ex-meter). Evita el
  "síndrome del elixir" (guardar recursos y nunca usarlos).

### Party (3 activos + 6 rotables)
- Cada compañero necesita **identidad mecánica de una frase** ("Maik rompe escudos").
  Si dos se sienten parecidos, uno sobra.
- **Incentivo de rotación**: banca gana XP igual + momentos de exploración que piden a un
  compañero específico (estilo Mario RPG).
- **Frappe** (mascota): darle función mecánica chica y visible (ej: olfatear materiales).

### Exploración
- Mapa chico + densidad alta: correcto para el equipo. 1 zona densa > 5 vacías.
- Coleccionables con oportunidad temática: **clips virales perdidos, merch de streamers
  caídos, memes fósiles** — lore del mundo pre-colapso como narrativa ambiental.

## 3. Sistemas RPG — adoptar / adaptar / cortar

| Sistema | Veredicto | Nota |
|---------|-----------|------|
| XP y niveles | ✅ Simplificado | Stats automáticos al subir. La personalización vive en el crafting. |
| Equipamiento | ✅ Mínimo | 2-3 slots (arma/armadura/accesorio), alimentado por crafting. |
| Economía | ⚠️ Cuidado | "Donaciones/Subs" como moneda; tiendas venden *materiales*, no equipo (no competir con el crafting). |
| Quests secundarias | ⚠️ Pocas | 5-8 escritas a mano, cada una un sketch. Nada de "matá 10 ratas". |
| Diálogo | ✅ Esencial | El juego ES el diálogo. Retratos con expresiones, timing, elección ocasional de respuesta (agencia cómica, estilo Monkey Island). |
| Guardado | ✅ Obligatorio | Puntos temáticos (router wifi) + autosave antes de jefes. |
| Dificultad | ✅ Barato | "Modo Historia / Normal". Amplía audiencia no-hardcore. |
| Bestiario | ✅ Encaja perfecto | Cada entrada es un chiste más. Barato, alto valor. |
| Estados | ✅ Ya diseñados | Regla: jefes con resistencia parcial (duración reducida), NUNCA inmunidad total, o las habilidades de estado mueren justo cuando importan. |
| Crafting | ✅ Sistema estrella | Ver arriba. |
| New Game+ | ❌ Cortar | Scope trap. Logros alcanzan para 5-6h. |
| Minijuegos | ⚠️ Máx 1-2 | Solo si un chiste lo necesita. |
| Romances/facciones/moralidad | ❌ Fuera | Scope traps clásicos de primer RPG. |

## 4. Herramientas (stack del equipo)

### Código
- **Godot 4.7** + **Git/GitHub** (ya en uso).
- Addons a evaluar cuando toque: **Dialogue Manager** (diálogos — liviano y programático,
  preferido sobre Dialogic para este caso), **Phantom Camera**, **AsepriteWizard**.

### Arte
- **Aseprite** (~USD 20): estándar para pixel art y animación. Compra obligada si van por pixel art.
- **Krita** (gratis): estilo dibujado, retratos de diálogo, concept art.
- **TileMapLayer nativo de Godot** para niveles; migrar a **LDtk** solo si queda chico.
- **Lospec.com**: paletas curadas. Restringir paleta temprano = arte amateur que se ve profesional.

### Audio (⚠️ rol sin asignar)
- **jsfxr / ChipTone** (gratis): SFX para prototipar.
- **Audacity** (gratis) / **LMMS** (gratis) / **Reaper** (USD 60).
- La música temática (parodias de intros de stream, lofi del apocalipsis) es una
  oportunidad cómica grande. Si aparece tercer integrante: audio + guión es rol perfecto.

### Producción
- **Trello/Notion**: Kanban simple (Ideas / Haciendo / Probando / Hecho).
- **docs/ del repo**: el GDD vive versionado junto al código.
- **itch.io** (página privada): distribución de builds de playtesting.

## 5. Decisiones a tomar pronto

1. **Arquetipos vs streamers reales** en jefes → recomendación fuerte: arquetipos.
2. **Identidad visual**: pixel art vs dibujado (decisión del artista; pixel art más viable de animar).
3. **Idioma del guión**: ¿rioplatense puro o pensado para localización? Afecta cada línea desde hoy.
4. **Rol de audio**: ¿tercer integrante, assets externos, o aprender lo básico?

## Veredicto

La idea es buena con estándar de "¿la financiaría un publisher chico?": tema con ventana,
coherencia temática rara en un primer diseño, scope sano. Los dos riesgos que la pueden
matar no son técnicos: el humor referencial mal manejado (→ arquetipos) y el burnout
(→ fases jugables + gate del vertical slice). Combate validado en prototipo; próxima
validación: el slice completo con gente ajena riéndose.
