class_name Combatant
extends RefCounted

## Un combatiente del sistema de batalla por turnos.
##
## Es LÓGICA PURA: no sabe nada de sprites, nodos ni pantalla. Solo maneja
## sus stats, su HP, su barra ATB "Buffering" y sus ESTADOS (Hype, Lag, etc.).
## La parte visual la resuelve battle.gd escuchando las señales de acá abajo.

## La barra ATB se llenó: le toca actuar.
signal acted
## Cambió el HP (para refrescar la barra de vida).
signal hp_changed(current: int, maximum: int)
## Cambiaron los estados activos (para refrescar el texto de estados).
signal status_changed
## El HP llegó a 0.
signal died

## Cuánto tiene que cargar la barra ATB (0 a 100) para poder actuar.
const ATB_MAX: float = 100.0
## Con Hype activo, el ataque se multiplica por esto.
const HYPE_ATTACK_MULTIPLIER: float = 1.5

# --- Stats base ---
var display_name: String
var max_hp: int
var attack: int
var defense: int
var speed: int      ## Cuánto ATB carga por segundo. Más SPD = actúa más seguido.
var technique: int  ## TEC: potencia de las habilidades especiales.

# --- Estado actual ---
var current_hp: int
var atb: float = 0.0
## Estados activos: nombre -> turnos restantes. Ej: {"hype": 3, "lag": 1}
var _statuses: Dictionary = {}


func _init(p_name: String, p_hp: int, p_atk: int, p_def: int, p_spd: int, p_tec: int) -> void:
	display_name = p_name
	max_hp = p_hp
	attack = p_atk
	defense = p_def
	speed = p_spd
	technique = p_tec
	current_hp = max_hp


func is_alive() -> bool:
	return current_hp > 0


## Avanza la barra ATB según la velocidad. Al llenarse, avisa con `acted`.
func tick(delta: float) -> void:
	if not is_alive():
		return
	atb += speed * delta
	if atb >= ATB_MAX:
		atb = 0.0
		acted.emit()


## Recibe un ataque ya calculado (mínimo 1 de daño; nunca 0).
func take_damage(incoming_attack: int) -> void:
	var damage: int = max(1, incoming_attack - defense)
	current_hp = max(0, current_hp - damage)
	hp_changed.emit(current_hp, max_hp)
	if current_hp == 0:
		died.emit()


# --------------------------------------------------------------------------
# Estados (Hype, Lag, y los que vengan)
# --------------------------------------------------------------------------

## Aplica (o refresca) un estado por una cantidad de turnos.
func apply_status(status_name: String, turns: int) -> void:
	_statuses[status_name] = turns
	status_changed.emit()


func has_status(status_name: String) -> bool:
	return _statuses.get(status_name, 0) > 0


## El ataque EFECTIVO, con Hype aplicado si está activo.
func effective_attack() -> int:
	if has_status("hype"):
		return int(round(attack * HYPE_ATTACK_MULTIPLIER))
	return attack


## Se llama cuando a este combatiente le toca actuar (su ATB se llenó).
## Devuelve false si está LAGGED (pierde el turno). Consume 1 turno de Lag
## y baja la duración de los buffs (el turno perdido igual "cuenta").
func begin_turn() -> bool:
	if has_status("lag"):
		_statuses["lag"] -= 1
		_tick_down_buffs()
		status_changed.emit()
		return false
	return true


## Se llama al terminar una acción normal: baja la duración de los buffs.
func end_turn() -> void:
	_tick_down_buffs()
	status_changed.emit()


func _tick_down_buffs() -> void:
	if _statuses.get("hype", 0) > 0:
		_statuses["hype"] -= 1


## Texto compacto de los estados activos, ej: "Hype 2 · Lag 1". Vacío si no hay.
func status_text() -> String:
	var parts: Array[String] = []
	for key: String in _statuses:
		if _statuses[key] > 0:
			parts.append("%s %d" % [key.capitalize(), _statuses[key]])
	return " · ".join(parts)
