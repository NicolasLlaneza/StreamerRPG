extends Node2D

## PROTOTIPO de batalla por turnos con ATB "Buffering", habilidades y estados.
##
## Las barras ATB cargan según SPD. Cuando se llena la del ENEMIGO, ataca solo.
## Cuando se llena la TUYA, el combate se PAUSA y elegís del menú:
##   • Atacar → daño físico normal.
##   • Mate   → te da HYPE (sube tu ataque x1.5 durante 3 turnos).
##   • Bomba  → daño (escala con TEC) y deja LAGGED al enemigo (pierde 1 turno).
##
## Interfaz creada por código para que la escena sea un solo nodo. Más adelante
## lo pasamos a escenas reales hechas en el editor.

var _player: Combatant
var _enemy: Combatant
var _battle_over: bool = false
var _waiting_for_player: bool = false

# Interfaz (se llena en _build_ui)
var _player_hp: ProgressBar
var _player_atb: ProgressBar
var _player_status: Label
var _enemy_hp: ProgressBar
var _enemy_atb: ProgressBar
var _enemy_status: Label
var _action_buttons: Array[Button] = []
var _log: RichTextLabel


func _ready() -> void:
	# Stats: (nombre, HP, ATK, DEF, SPD, TEC)
	_player = Combatant.new("Protagonista", 60, 14, 4, 45, 12)
	_enemy = Combatant.new("Fan Toxico", 90, 11, 6, 30, 4)

	_build_ui()

	_player.acted.connect(_on_player_ready)
	_enemy.acted.connect(_on_enemy_ready)

	_player.hp_changed.connect(func(current: int, _maximum: int) -> void:
		_player_hp.value = current)
	_enemy.hp_changed.connect(func(current: int, _maximum: int) -> void:
		_enemy_hp.value = current)

	_player.status_changed.connect(func() -> void:
		_player_status.text = _player.status_text())
	_enemy.status_changed.connect(func() -> void:
		_enemy_status.text = _enemy.status_text())

	_player.died.connect(_on_died.bind(_player))
	_enemy.died.connect(_on_died.bind(_enemy))

	_log_line("[b]Empieza la batalla![/b] Cuando se llene tu barra, elegí una acción.")


func _process(delta: float) -> void:
	if _battle_over or _waiting_for_player:
		return
	_player.tick(delta)
	_enemy.tick(delta)
	_player_atb.value = _player.atb
	_enemy_atb.value = _enemy.atb


# --------------------------------------------------------------------------
# Turnos
# --------------------------------------------------------------------------

## Le toca al jugador: chequeamos Lag, y si puede actuar mostramos el menú.
func _on_player_ready() -> void:
	if _battle_over:
		return
	if not _player.begin_turn():
		_log_line("[color=orange]Estás LAGGED! Perdés el turno.[/color]")
		return  # el tiempo se reanuda solo (no pausamos)
	_waiting_for_player = true
	_set_menu_visible(true)
	_log_line("[color=aqua]Tu turno![/color] Elegí una acción.")


## Le toca al enemigo (automático): chequea Lag y ataca.
func _on_enemy_ready() -> void:
	if _battle_over or not _enemy.is_alive():
		return
	if not _enemy.begin_turn():
		_log_line("[color=orange]%s está LAGGED y pierde el turno![/color]" % _enemy.display_name)
		return
	_deal_attack(_enemy, _player)
	_enemy.end_turn()


# --- Acciones del jugador (una por botón del menú) ---

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


## Cierra el turno del jugador: baja buffs, oculta el menú y reanuda el tiempo.
func _finish_player_turn() -> void:
	_player.end_turn()
	_set_menu_visible(false)
	_waiting_for_player = false


# --- Utilidades de combate ---

## Ataque físico de `attacker` a `target`, usando el ataque efectivo (con Hype).
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
# Interfaz (placeholder). Se reemplaza por escenas reales pronto.
# --------------------------------------------------------------------------
func _build_ui() -> void:
	_player_hp = ProgressBar.new()
	_player_atb = ProgressBar.new()
	_player_status = Label.new()
	_enemy_hp = ProgressBar.new()
	_enemy_atb = ProgressBar.new()
	_enemy_status = Label.new()

	_make_panel(_player, Color(0.30, 0.50, 0.90), 200.0, _player_hp, _player_atb, _player_status)
	_make_panel(_enemy, Color(0.90, 0.35, 0.30), 880.0, _enemy_hp, _enemy_atb, _enemy_status)

	# Menú de acciones (oculto hasta tu turno).
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


func _make_panel(cbt: Combatant, color: Color, x: float, hp_bar: ProgressBar, atb_bar: ProgressBar, status_label: Label) -> void:
	var body := ColorRect.new()
	body.color = color
	body.position = Vector2(x, 210.0)
	body.size = Vector2(120.0, 160.0)
	add_child(body)

	var name_label := Label.new()
	name_label.text = cbt.display_name
	name_label.position = Vector2(x, 180.0)
	add_child(name_label)

	status_label.position = Vector2(x, 378.0)
	status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	add_child(status_label)

	hp_bar.max_value = cbt.max_hp
	hp_bar.value = cbt.current_hp
	hp_bar.position = Vector2(x, 402.0)
	hp_bar.size = Vector2(180.0, 22.0)
	add_child(hp_bar)

	atb_bar.max_value = Combatant.ATB_MAX
	atb_bar.value = 0.0
	atb_bar.modulate = Color(1.0, 0.85, 0.2)
	atb_bar.position = Vector2(x, 430.0)
	atb_bar.size = Vector2(180.0, 12.0)
	add_child(atb_bar)


func _log_line(text: String) -> void:
	_log.append_text(text + "\n")
