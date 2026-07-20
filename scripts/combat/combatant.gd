class_name Combatant
extends RefCounted

## Un combatiente del sistema de batalla por turnos.
##
## Es LÓGICA PURA: no sabe nada de sprites, nodos ni pantalla. Solo maneja
## sus stats, su HP y su barra ATB "Buffering". La parte visual la resuelve
## quien lo use (battle.gd), escuchando las señales de acá abajo.
##
## Separar la lógica de lo visual es una de las mejores costumbres en Godot:
## te deja cambiar los gráficos sin tocar las reglas del juego.

## Se emite cuando la barra ATB se llenó y a este combatiente le toca actuar.
signal acted
## Se emite cuando cambia el HP (para refrescar la barra de vida en pantalla).
signal hp_changed(current: int, maximum: int)
## Se emite cuando el HP llega a 0.
signal died

## Cuánto tiene que cargar la barra ATB (de 0 a 100) para poder actuar.
const ATB_MAX: float = 100.0

# --- Stats base (se definen al crear el combatiente) ---
var display_name: String
var max_hp: int
var attack: int
var defense: int
var speed: int  ## Cuántos puntos de ATB carga por segundo. Más SPD = actúa más seguido.

# --- Estado actual ---
var current_hp: int
var atb: float = 0.0


func _init(p_name: String, p_hp: int, p_atk: int, p_def: int, p_spd: int) -> void:
	display_name = p_name
	max_hp = p_hp
	attack = p_atk
	defense = p_def
	speed = p_spd
	current_hp = max_hp


func is_alive() -> bool:
	return current_hp > 0


## Avanza la barra ATB según la velocidad. Cuando se llena, avisa con `acted`
## y vuelve a cero. Esto es el corazón del sistema "Buffering": los rápidos
## actúan más seguido, pero nadie rompe el ritmo por turnos.
func tick(delta: float) -> void:
	if not is_alive():
		return
	atb += speed * delta
	if atb >= ATB_MAX:
		atb = 0.0
		acted.emit()


## Recibe un ataque. El daño real es el ataque del rival menos la defensa
## propia, con un mínimo de 1 (nunca un golpe hace 0).
func take_damage(incoming_attack: int) -> void:
	var damage: int = max(1, incoming_attack - defense)
	current_hp = max(0, current_hp - damage)
	hp_changed.emit(current_hp, max_hp)
	if current_hp == 0:
		died.emit()
