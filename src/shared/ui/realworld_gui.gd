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

	# Signal verbinden, falls noch nicht verbunden
	if not SaveManager.player_stats_changed.is_connected(_on_player_stats_changed):
		SaveManager.player_stats_changed.connect(_on_player_stats_changed)

	# Prüfen, ob bereits Player-Stats freigeschaltet sind (z.B. beim Continue)
	for stat in SaveManager.save_data["player_stats"]:
		if SaveManager.save_data["player_stats"][stat]:
			_on_player_stats_changed(stat, true) # direkt aufrufen, um HUD zu aktivieren

	# Player-abhängige Sichtbarkeit erst prüfen, wenn Player existiert
	_wait_for_player()


# Neue Funktion, wartet bis Player existiert
func _wait_for_player() -> void:
	while not GlobalScript.player:
		await get_tree().process_frame
	# Jetzt Player existiert -> HUD aktualisieren
	unlocked = SaveManager.has_any_player_stat_unlocked()
	_update_icons()
	_update_visibility()

func _process(_delta):
	_update_visibility()
	
func _on_player_stats_changed(_stat, _value):
	unlocked = SaveManager.has_any_player_stat_unlocked()
	_update_visibility()
	_update_icons()
	
# -----------------------------------------
# Sichtbarkeit prüfen
# -----------------------------------------
func _update_visibility():
	if not unlocked:
		visible = false
		return

	if GlobalScript.transition_scene:
		visible = false
		return

	var player := GlobalScript.player
	if not player or not is_instance_valid(player):
		visible = false
		return

	if not (player is PlayerRealworld):
		visible = false
		return

	if get_tree().current_scene.name == "MainMenu":
		visible = false
		return

	visible = true
	
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
	if "is_busy" in GlobalScript.player and GlobalScript.player.is_busy:
		phone.self_modulate = Color(1,1,1,0.35)
	else:
		phone.self_modulate = Color(1,1,1,1)

# -----------------------------------------
# Hilfsfunktion zum Icons aus-/einblenden
# -----------------------------------------
func _set_icon(icon: TextureRect, unlocked: bool):
	icon.self_modulate = Color(1,1,1,1) if unlocked else Color(1,1,1,0.35)
