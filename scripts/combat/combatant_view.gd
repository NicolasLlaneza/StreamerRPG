class_name CombatantView
extends Node2D

## VISTA (parte visual) de un combatiente.
##
## Se arma como una escena reusable (CombatantView.tscn) y se conecta a un
## Combatant (la lógica) con bind(). La vista solo dibuja: escucha las señales
## del combatiente y refresca barras y textos. No decide nada del combate.
##
## Esta separación es la clave: tu compañero puede reemplazar el rectángulo por
## un sprite y mover las barras en el editor, sin tocar una línea de lógica.

# $Body busca un nodo hijo llamado exactamente "Body". Por eso los nombres de
# los nodos en la escena TIENEN que coincidir con estos.
@onready var _body: ColorRect = $Body
@onready var _name_label: Label = $NameLabel
@onready var _status_label: Label = $StatusLabel
@onready var _hp_bar: ProgressBar = $HPBar
@onready var _atb_bar: ProgressBar = $ATBBar

var _combatant: Combatant


func _ready() -> void:
	# Ubicamos los elementos por código para que no tengas que pelear con los
	# anclajes de Godot en tu primera escena. Cuando pongan sprites de verdad,
	# podés reacomodar todo acá o directamente arrastrando en el editor.
	_name_label.position = Vector2(0, 0)
	_body.position = Vector2(0, 30)
	_body.size = Vector2(120, 160)
	_status_label.position = Vector2(0, 198)
	_status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	_hp_bar.position = Vector2(0, 222)
	_hp_bar.size = Vector2(180, 22)
	_atb_bar.position = Vector2(0, 250)
	_atb_bar.size = Vector2(180, 12)
	_atb_bar.modulate = Color(1.0, 0.85, 0.2)


## Conecta esta vista a un combatiente (su lógica) y pinta su estado inicial.
## Se llama DESPUÉS de agregar la vista al árbol, así los @onready ya existen.
func bind(combatant: Combatant, color: Color) -> void:
	_combatant = combatant
	_body.color = color
	_name_label.text = combatant.display_name
	_hp_bar.max_value = combatant.max_hp
	_hp_bar.value = combatant.current_hp
	_atb_bar.max_value = Combatant.ATB_MAX
	_atb_bar.value = 0.0
	_status_label.text = ""

	# La vista escucha a la lógica: cuando cambia el HP o los estados, se pinta.
	combatant.hp_changed.connect(func(current: int, _maximum: int) -> void:
		_hp_bar.value = current)
	combatant.status_changed.connect(func() -> void:
		_status_label.text = _combatant.status_text())


## Refresca la barra ATB. La llama battle.gd cada frame.
func update_atb() -> void:
	_atb_bar.value = _combatant.atb
