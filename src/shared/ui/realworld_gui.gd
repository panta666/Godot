extends CanvasLayer

@onready var crouch_icon: TextureRect = $Control/PanelContainer/HBoxContainer/CrouchIcon
@onready var double_jump_icon: TextureRect = $Control/PanelContainer/HBoxContainer/DoubleJumpIcon
@onready var dash_icon: TextureRect = $Control/PanelContainer/HBoxContainer/DashIcon
@onready var range_attack_icon: TextureRect = $Control/PanelContainer/HBoxContainer/RangeAttackIcon
@onready var heal_icon: TextureRect = $Control/PanelContainer/HBoxContainer/HealIcon
@onready var phone: TextureRect = $Control/Phone

func _ready():
	# Erstmal ausblenden, wenn wir nicht Realworld sind
	_update_visibility()
	_update_icons()

	# Shop-Update Signal
	if not SaveManager.shop_unlocked_signal.is_connected(_update_icons):
		SaveManager.shop_unlocked_signal.connect(_update_icons)

	# Falls Player später gesetzt wird, Frame-Prüfung
	get_tree().process_frame.connect(_on_frame)

func _on_frame():
	_update_visibility()
	_update_icons()

func _update_visibility():
	if GlobalScript.player is PlayerRealworld and get_tree().current_scene.name != "MainMenu":
		visible = true
	else:
		visible = false

func _update_icons():
	# PowerUp-Icons
	_set_icon(crouch_icon, SaveManager.is_player_stat_unlocked("crouching"))
	_set_icon(double_jump_icon, SaveManager.is_player_stat_unlocked("double_jump"))
	_set_icon(dash_icon, SaveManager.is_player_stat_unlocked("dash"))
	_set_icon(range_attack_icon, SaveManager.is_player_stat_unlocked("range_attack"))
	_set_icon(heal_icon, SaveManager.is_player_stat_unlocked("heal_ability"))

	# Handy ausgrauen, wenn Player beschäftigt
	if GlobalScript.player is PlayerRealworld:
		if GlobalScript.player.is_busy:
			phone.self_modulate = Color(1,1,1,0.35)
		else:
			phone.self_modulate = Color(1,1,1,1)
	else:
		phone.self_modulate = Color(1,1,1,1)

func _set_icon(icon: TextureRect, unlocked: bool):
	if unlocked:
		icon.self_modulate = Color(1, 1, 1, 1)      # normal
	else:
		icon.self_modulate = Color(1, 1, 1, 0.35)   # ausgegraut
