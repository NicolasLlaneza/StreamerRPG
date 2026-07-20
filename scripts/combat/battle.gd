extends Node2D

## PROTOTIPO de batalla por turnos con barra ATB ("Buffering").
##
## Las barras ATB se cargan según la velocidad (SPD). Cuando se llena la del
## ENEMIGO, ataca solo. Cuando se llena la TUYA, el combate se PAUSA y espera
## que elijas una acción con el botón "Atacar" (modo "wait", más tranquilo y
## estratégico). Así el jugador tiene control real del turno.
##
## Toda la interfaz se crea por código para que la escena sea un solo nodo.
## Más adelante lo pasamos a escenas de verdad hechas en el editor.

var _player: Combatant
var _enemy: Combatant
var _battle_over: bool = false
## Mientras es true, el tiempo se congela esperando que el jugador elija.
var _waiting_for_player: bool = false

# Referencias a la interfaz (se llenan en _build_ui)
var _player_hp: ProgressBar
var _player_atb: ProgressBar
var _enemy_hp: ProgressBar
var _enemy_atb: ProgressBar
var _attack_button: Button
var _log: RichTextLabel


func _ready() -> void:
	_player = Combatant.new("Protagonista", 60, 14, 4, 45)
	_enemy = Combatant.new("Fan Toxico", 80, 10, 6, 30)

	_build_ui()

	# El enemigo actúa solo. El jugador, en cambio, PAUSA y espera tu decisión.
	_player.acted.connect(_on_player_ready)
	_enemy.acted.connect(_on_combatant_acted.bind(_enemy, _player))

	_player.hp_changed.connect(func(current: int, _maximum: int) -> void:
		_player_hp.value = current)
	_enemy.hp_changed.connect(func(current: int, _maximum: int) -> void:
		_enemy_hp.value = current)

	_player.died.connect(_on_died.bind(_player))
	_enemy.died.connect(_on_died.bind(_enemy))

	_log_line("[b]Empieza la batalla![/b] Cuando se llene tu barra, elegí una acción.")


func _process(delta: float) -> void:
	# Si la batalla terminó o estamos esperando al jugador, el tiempo se congela.
	if _battle_over or _waiting_for_player:
		return
	_player.tick(delta)
	_enemy.tick(delta)
	_player_atb.value = _player.atb
	_enemy_atb.value = _enemy.atb


## La barra del jugador se llenó: paramos el tiempo y ofrecemos acciones.
func _on_player_ready() -> void:
	if _battle_over:
		return
	_waiting_for_player = true
	_attack_button.disabled = false
	_attack_button.visible = true
	_log_line("[color=aqua]Tu turno![/color] Elegí una acción.")


## El jugador apretó "Atacar".
func _on_attack_pressed() -> void:
	if not _waiting_for_player:
		return
	_attack_button.disabled = true
	_attack_button.visible = false
	_on_combatant_acted(_player, _enemy)
	# Reanudamos el tiempo: las barras vuelven a cargar.
	_waiting_for_player = false


## Resuelve un ataque de `attacker` sobre `target`. Sirve para ambos bandos.
func _on_combatant_acted(attacker: Combatant, target: Combatant) -> void:
	if _battle_over or not attacker.is_alive() or not target.is_alive():
		return
	var hp_before: int = target.current_hp
	target.take_damage(attacker.attack)
	var dealt: int = hp_before - target.current_hp
	_log_line("%s ataca a %s por %d de daño." % [attacker.display_name, target.display_name, dealt])


func _on_died(who: Combatant) -> void:
	_battle_over = true
	_attack_button.visible = false
	var player_won: bool = who == _enemy
	var result: String = "Ganaste!" if player_won else "Perdiste..."
	_log_line("[b]%s cayo. %s[/b]" % [who.display_name, result])


# --------------------------------------------------------------------------
# Interfaz (placeholder). Todo esto lo reemplazamos por escenas reales pronto.
# --------------------------------------------------------------------------
func _build_ui() -> void:
	_player_hp = ProgressBar.new()
	_player_atb = ProgressBar.new()
	_enemy_hp = ProgressBar.new()
	_enemy_atb = ProgressBar.new()

	_make_panel(_player, Color(0.30, 0.50, 0.90), 200.0, _player_hp, _player_atb)
	_make_panel(_enemy, Color(0.90, 0.35, 0.30), 880.0, _enemy_hp, _enemy_atb)

	# Botón de acción del jugador (oculto hasta que sea tu turno).
	_attack_button = Button.new()
	_attack_button.text = "Atacar"
	_attack_button.position = Vector2(200.0, 460.0)
	_attack_button.size = Vector2(180.0, 44.0)
	_attack_button.visible = false
	_attack_button.pressed.connect(_on_attack_pressed)
	add_child(_attack_button)

	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.position = Vector2(440.0, 460.0)
	_log.size = Vector2(720.0, 200.0)
	add_child(_log)


func _make_panel(cbt: Combatant, color: Color, x: float, hp_bar: ProgressBar, atb_bar: ProgressBar) -> void:
	var body := ColorRect.new()
	body.color = color
	body.position = Vector2(x, 220.0)
	body.size = Vector2(120.0, 160.0)
	add_child(body)

	var name_label := Label.new()
	name_label.text = cbt.display_name
	name_label.position = Vector2(x, 190.0)
	add_child(name_label)

	hp_bar.max_value = cbt.max_hp
	hp_bar.value = cbt.current_hp
	hp_bar.position = Vector2(x, 400.0)
	hp_bar.size = Vector2(180.0, 22.0)
	add_child(hp_bar)

	atb_bar.max_value = Combatant.ATB_MAX
	atb_bar.value = 0.0
	atb_bar.modulate = Color(1.0, 0.85, 0.2)  # amarillo = "cargando"
	atb_bar.position = Vector2(x, 428.0)
	atb_bar.size = Vector2(180.0, 12.0)
	add_child(atb_bar)


func _log_line(text: String) -> void:
	_log.append_text(text + "\n")
