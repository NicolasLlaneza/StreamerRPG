extends Node2D

## PROTOTIPO de batalla por turnos con barra ATB ("Buffering").
##
## Dos combatientes cargan su barra ATB según su velocidad (SPD). Cuando la
## barra de uno se llena, ataca al otro. Todo se auto-juega: por ahora no hay
## botones, porque lo que queremos PROBAR primero es si el RITMO del combate
## se siente bien. La interacción del jugador viene en el próximo paso.
##
## Toda la interfaz se crea por código en _build_ui() para que solo tengas que
## armar una escena con un Node2D y darle Play. Más adelante lo pasamos a
## escenas de verdad hechas en el editor.

var _player: Combatant
var _enemy: Combatant
var _battle_over: bool = false

# Referencias a la interfaz (se llenan en _build_ui)
var _player_hp: ProgressBar
var _player_atb: ProgressBar
var _enemy_hp: ProgressBar
var _enemy_atb: ProgressBar
var _log: RichTextLabel


func _ready() -> void:
	# Creamos los dos combatientes con stats de prueba.
	# Protagonista: rápido y pega fuerte (rol Daño). Enemigo: lento y aguanta.
	_player = Combatant.new("Protagonista", 60, 14, 4, 45)
	_enemy = Combatant.new("Fan Toxico", 80, 10, 6, 30)

	_build_ui()

	# Conectamos las señales de cada combatiente a la lógica de batalla.
	# .bind(...) le "pega" argumentos extra a la señal: acá le decimos quién
	# ataca y a quién, para reusar la misma función en ambos.
	_player.acted.connect(_on_combatant_acted.bind(_player, _enemy))
	_enemy.acted.connect(_on_combatant_acted.bind(_enemy, _player))

	_player.hp_changed.connect(func(current: int, _maximum: int) -> void:
		_player_hp.value = current)
	_enemy.hp_changed.connect(func(current: int, _maximum: int) -> void:
		_enemy_hp.value = current)

	_player.died.connect(_on_died.bind(_player))
	_enemy.died.connect(_on_died.bind(_enemy))

	_log_line("[b]Empieza la batalla![/b] Las barras ATB se cargan segun la velocidad.")


func _process(delta: float) -> void:
	if _battle_over:
		return
	# Cada frame avanzamos las dos barras ATB...
	_player.tick(delta)
	_enemy.tick(delta)
	# ...y las reflejamos en pantalla.
	_player_atb.value = _player.atb
	_enemy_atb.value = _enemy.atb


## Se dispara cuando a un combatiente le toca actuar (su barra ATB se llenó).
func _on_combatant_acted(attacker: Combatant, target: Combatant) -> void:
	if _battle_over or not attacker.is_alive() or not target.is_alive():
		return
	var hp_before: int = target.current_hp
	target.take_damage(attacker.attack)
	var dealt: int = hp_before - target.current_hp
	_log_line("%s ataca a %s por %d de daño." % [attacker.display_name, target.display_name, dealt])


func _on_died(who: Combatant) -> void:
	_battle_over = true
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

	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.position = Vector2(120.0, 480.0)
	_log.size = Vector2(1040.0, 180.0)
	add_child(_log)


## Arma el bloque visual de un combatiente: cuerpo (rectángulo), nombre,
## barra de vida y barra ATB.
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
