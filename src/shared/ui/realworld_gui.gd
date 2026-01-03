extends CanvasLayer

@onready var crouch_icon: TextureRect = $Control/PanelContainer/HBoxContainer/CrouchIcon
@onready var double_jump_icon: TextureRect = $Control/PanelContainer/HBoxContainer/DoubleJumpIcon
@onready var dash_icon: TextureRect = $Control/PanelContainer/HBoxContainer/DashIcon
@onready var range_attack_icon: TextureRect = $Control/PanelContainer/HBoxContainer/RangeAttackIcon
@onready var heal_icon: TextureRect = $Control/PanelContainer/HBoxContainer/HealIcon
@onready var phone: TextureRect = $Control/Phone

# HUD erst sichtbar, wenn mindestens ein PowerUp freigeschaltet ist
var unlocked: bool = false

func _ready():
	# HUD initial unsichtbar
	visible = false
	_update_icons()

	# Shop-Update Signal: wird gefeuert, wenn ein PowerUp gekauft/erhalten wird
	if not SaveManager.shop_unlocked_signal.is_connected(_on_powerup_unlocked):
		SaveManager.shop_unlocked_signal.connect(_on_powerup_unlocked)

	# Frame-Update für Sichtbarkeit und Icons
	get_tree().process_frame.connect(_on_frame)

func _on_frame():
	_update_visibility()
	_update_icons()

# -----------------------------------------
# Signal Callback: PowerUp wurde freigeschaltet
# -----------------------------------------
func _on_powerup_unlocked():
	unlocked = true
	_update_visibility()
	_update_icons()

# -----------------------------------------
# Sichtbarkeit prüfen
# -----------------------------------------
func _update_visibility():
	# HUD aus während Transition
	if GlobalScript.transition_scene:
		visible = false
		return

	# Wenn HUD nicht im Tree
	if not is_inside_tree():
		visible = false
		return

	# Aktuelle Szene prüfen
	var scene := get_tree().current_scene
	if scene == null:
		visible = false
		return

	# Player prüfen (kann null oder invalid sein)
	var player_exists := GlobalScript.player != null and is_instance_valid(GlobalScript.player)
	var is_realworld_player := player_exists and GlobalScript.player is PlayerRealworld
	var not_mainmenu := scene.name != "MainMenu"

	# HUD nur anzeigen, wenn freigeschaltet, Player existiert, Realworld, keine MainMenu und keine Transition
	visible = unlocked and is_realworld_player and not_mainmenu and not GlobalScript.transition_scene

# -----------------------------------------
# Icons updaten
# -----------------------------------------
func _update_icons():
	# Wenn HUD noch nicht freigeschaltet oder Player weg, Icons ausgrauen
	var player_exists := GlobalScript.player != null and is_instance_valid(GlobalScript.player)
	if not unlocked or not player_exists:
		_set_icon(crouch_icon, false)
		_set_icon(double_jump_icon, false)
		_set_icon(dash_icon, false)
		_set_icon(range_attack_icon, false)
		_set_icon(heal_icon, false)
		phone.self_modulate = Color(1,1,1,0.35)
		return

	# Icons entsprechend freigeschaltet oder nicht
	_set_icon(crouch_icon, SaveManager.is_player_stat_unlocked("crouching"))
	_set_icon(double_jump_icon, SaveManager.is_player_stat_unlocked("double_jump"))
	_set_icon(dash_icon, SaveManager.is_player_stat_unlocked("dash"))
	_set_icon(range_attack_icon, SaveManager.is_player_stat_unlocked("range_attack"))
	_set_icon(heal_icon, SaveManager.is_player_stat_unlocked("heal_ability"))

	# Handy ausgrauen, wenn Player beschäftigt
	if GlobalScript.player.is_busy:
		phone.self_modulate = Color(1,1,1,0.35)
	else:
		phone.self_modulate = Color(1,1,1,1)

# -----------------------------------------
# Hilfsfunktion zum Icons aus-/einblenden
# -----------------------------------------
func _set_icon(icon: TextureRect, unlocked: bool):
	icon.self_modulate = Color(1,1,1,1) if unlocked else Color(1,1,1,0.35)
