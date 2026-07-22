extends Node2D

## Batalla por turnos con ATB "Buffering", habilidades y estados.
##
## Cambio importante respecto a la versión anterior: ya NO dibujamos cada
## combatiente a mano. Instanciamos la escena reusable combatant_view.tscn,
## que se encarga sola de mostrar barras, nombre y estados. Este script pasa a
## ocuparse solo de las REGLAS del combate.
##
## Ese es el patrón central de Godot: una escena reusable + instanciarla N veces.
## Cuando sumemos la party de 3, es literalmente una línea más por personaje.

## preload() carga la escena al compilar. Es la forma recomendada cuando la ruta
## es fija: si el archivo no existe, te avisa enseguida y no en pleno combate.
const COMBATANT_VIEW_SCENE := preload("res://scenes/combat/combatant_view.tscn")

var _player: Combatant
var _enemy: Combatant
var _player_view: CombatantView
var _enemy_view: CombatantView

var _battle_over: bool = false
var _waiting_for_player: bool = false

# Interfaz propia de la batalla (menú y log). Las barras ahora viven en la vista.
var _action_buttons: Array[Button] = []
var _log: RichTextLabel


func _ready() -> void:
	# Stats: (nombre, HP, ATK, DEF, SPD, TEC)
	_player = Combatant.new("Protagonista", 60, 14, 4, 45, 12)
	_enemy = Combatant.new("Fan Toxico", 90, 11, 6, 30, 4)

	_player_view = _spawn_view(_player, Color(0.30, 0.50, 0.90), Vector2(200.0, 180.0))
	_enemy_view = _spawn_view(_enemy, Color(0.90, 0.35, 0.30), Vector2(880.0, 180.0))

	_build_battle_ui()

	_player.acted.connect(_on_player_ready)
	_enemy.acted.connect(_on_enemy_ready)
	_player.died.connect(_on_died.bind(_player))
	_enemy.died.connect(_on_died.bind(_enemy))

	_log_line("[b]Empieza la batalla![/b] Cuando se llene tu barra, elegí una acción.")


## Crea una vista para un combatiente y la deja lista en pantalla.
func _spawn_view(combatant: Combatant, color: Color, pos: Vector2) -> CombatantView:
	var view: CombatantView = COMBATANT_VIEW_SCENE.instantiate()
	view.position = pos
	# Primero al árbol (ahí corre su _ready y sus @onready quedan listos)...
	add_child(view)
	# ...y recién después la conectamos con la lógica.
	view.bind(combatant, color)
	return view


func _process(delta: float) -> void:
	if _battle_over or _waiting_for_player:
		return
	_player.tick(delta)
	_enemy.tick(delta)
	# Cada vista refresca su propia barra ATB.
	_player_view.update_atb()
	_enemy_view.update_atb()


# --------------------------------------------------------------------------
# Turnos
# --------------------------------------------------------------------------

func _on_player_ready() -> void:
	if _battle_over:
		return
	if not _player.begin_turn():
		_log_line("[color=orange]Estás LAGGED! Perdés el turno.[/color]")
		return
	_waiting_for_player = true
	_set_menu_visible(true)
	_log_line("[color=aqua]Tu turno![/color] Elegí una acción.")


func _on_enemy_ready() -> void:
	if _battle_over or not _enemy.is_alive():
		return
	if not _enemy.begin_turn():
		_log_line("[color=orange]%s está LAGGED y pierde el turno![/color]" % _enemy.display_name)
		return
	_deal_attack(_enemy, _player)
	_enemy.end_turn()


# --- Acciones del jugador ---

func _on_attack_pressed() -> void:
	if not _waiting_for_player:
		return
	_deal_attack(_player, _enemy)
	_finish_player_turn()


func _on_mate_pressed() -> void:
	if not _waiting_for_player:
		return
	_player.apply_status("hype", 3)
	_log_line("%s se ceba un mate y entra en [color=yellow]HYPE[/color]! (ATK x1.5)" % _player.display_name)
	_finish_player_turn()


func _on_bomba_pressed() -> void:
	if not _waiting_for_player:
		return
	var power: int = _player.technique * 2
	var before: int = _enemy.current_hp
	_enemy.take_damage(power)
	var dealt: int = before - _enemy.current_hp
	_enemy.apply_status("lag", 1)
	_log_line("%s lanza una Bomba Colortov: %d de daño y deja [color=orange]LAGGED[/color] al enemigo!" % [_player.display_name, dealt])
	_finish_player_turn()


func _finish_player_turn() -> void:
	_player.end_turn()
	_set_menu_visible(false)
	_waiting_for_player = false


# --- Utilidades de combate ---

func _deal_attack(attacker: Combatant, target: Combatant) -> void:
	if not attacker.is_alive() or not target.is_alive():
		return
	var before: int = target.current_hp
	target.take_damage(attacker.effective_attack())
	var dealt: int = before - target.current_hp
	_log_line("%s ataca a %s por %d de daño." % [attacker.display_name, target.display_name, dealt])


func _on_died(who: Combatant) -> void:
	_battle_over = true
	_set_menu_visible(false)
	var player_won: bool = who == _enemy
	var result: String = "Ganaste!" if player_won else "Perdiste..."
	_log_line("[b]%s cayó. %s[/b]" % [who.display_name, result])


# --------------------------------------------------------------------------
# Interfaz de la batalla (menú de acciones + log)
# --------------------------------------------------------------------------

func _build_battle_ui() -> void:
	_add_action_button("Atacar", 0, _on_attack_pressed)
	_add_action_button("Mate (Hype)", 1, _on_mate_pressed)
	_add_action_button("Bomba (Lag)", 2, _on_bomba_pressed)

	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.position = Vector2(440.0, 470.0)
	_log.size = Vector2(720.0, 190.0)
	add_child(_log)


func _add_action_button(text: String, index: int, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.position = Vector2(200.0, 470.0 + index * 52.0)
	button.size = Vector2(200.0, 44.0)
	button.visible = false
	button.pressed.connect(callback)
	add_child(button)
	_action_buttons.append(button)


func _set_menu_visible(is_visible: bool) -> void:
	for button: Button in _action_buttons:
		button.visible = is_visible
		button.disabled = not is_visible


func _log_line(text: String) -> void:
	_log.append_text(text + "\n")
