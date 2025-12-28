extends CanvasLayer

# --- Onready-Referenzen ---
@onready var control: Control = $Control
@onready var menu_container: VBoxContainer = $Control/MenuContainer
@onready var menu_options: VBoxContainer = $Control/MenuContainer/MenuOptions
@onready var options_container: Control = $Control/OptionsContainer


# --- Menü-Buttons ---
@onready var continue_button: Button = $Control/MenuContainer/MenuOptions/Continue
@onready var save_button: Button = $Control/MenuContainer/MenuOptions/Save
@onready var options_button: Button = $Control/MenuContainer/MenuOptions/Options
@onready var credits_button: Button = $Control/MenuContainer/MenuOptions/Credits
@onready var quit_button: Button = $Control/MenuContainer/MenuOptions/Quit


# --- Phone / PowerArea ---
@onready var phone: Sprite2D = $Control/Phone
@onready var phone_background: AnimatedSprite2D = $Control/PhoneScreenContainer/Background
@onready var back: Area2D = $Control/Phone/PowerArea

# --- Tutorial ---
@onready var blinking: Node2D = $Control/Blinking


# --------------------------
# Drag & Drop
var dragging := false
var drag_offset := Vector2.ZERO

# --------------------------
# Menü-Status
var is_transitioning: bool = false

func _ready() -> void:
	GlobalScript.esc_menu_instance = self
	process_mode = Node.ProcessMode.PROCESS_MODE_ALWAYS
	back.input_event.connect(_on_back_pressed)

	# Menü unsichtbar starten
	menu_container.visible = false
	options_container.visible = false
	phone.visible = false
	phone_background.visible = false
	
	blinking.visible = true
	set_process_input(true)
	
# Tutorial: Quit/Wake Up Button ausblenden
	if get_tree().current_scene.name == "dreamworld_tutorial":
		if quit_button:
			quit_button.visible = false

# --------------------------
# ESC-Taste
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("esc_menu"):
		var player = GlobalScript.player
		var player_dw = GlobalScript.player_dw

		if not player and not player_dw:
			print("[ESC_MENU] Kein Player gefunden")
			return

		# Realworld blockiert Transition
		if player and (is_transitioning or player.is_busy):
			print("[ESC_MENU] ESC blockiert | is_transitioning=", is_transitioning, " | player.is_busy=", player.is_busy)
			return

		print("[ESC_MENU] ESC gedrückt | Menü wird geöffnet/geschlossen")

		if menu_container.visible or options_container.visible:
			close_menu()
		else:
			open_menu()

# --------------------------
func open_menu() -> void:
	var player = GlobalScript.player
	var player_dw = GlobalScript.player_dw
	
	# Button-Text für Dreamworld / Realworld anpassen
	if player_dw and is_instance_valid(player_dw):
		quit_button.text = "Wake Up"
	else:
		quit_button.text = "Quit"
		
	if player and is_instance_valid(player):
		is_transitioning = true
		player.can_move = false
		player.can_interact = false
		player.open_mobile(Callable(self, "_on_open_mobile_finished"))

	if player_dw and is_instance_valid(player_dw):
		get_tree().paused = true
		print("[ESC_MENU] Dreamworld pausiert")
		# kein is_transitioning setzen!

	menu_container.visible = true
	options_container.visible = false
	phone.visible = true
	phone_background.visible = true

func _on_open_mobile_finished() -> void:
	print("[ESC_MENU] _on_open_mobile_finished() aufgerufen")
	is_transitioning = false

	var player = GlobalScript.player
	if player:
		print("[ESC_MENU] Nach open_mobile | can_move=", player.can_move, " can_interact=", player.can_interact)

# --------------------------
# Menü schließen
func close_menu() -> void:
	var player = GlobalScript.player
	var player_dw = GlobalScript.player_dw

	# Dreamworld
	if player_dw and is_instance_valid(player_dw):
		get_tree().paused = false
		menu_container.visible = false
		options_container.visible = false
		phone.visible = false
		phone_background.visible = false
		blinking.visible = false
		print("[ESC_MENU] Dreamworld Pause beendet")
		is_transitioning = false
		return

	# Realworld
	if not player or not is_instance_valid(player):
		print("[ESC_MENU] Kein Player gefunden beim Schließen")
		return

	if is_transitioning:
		print("[ESC_MENU] close_menu() abgebrochen, is_transitioning=true")
		return

	is_transitioning = true
	player.close_mobile(Callable(self, "_on_close_mobile_finished"))
	is_transitioning = false

func _on_close_mobile_finished() -> void:
	print("[ESC_MENU] _on_close_mobile_finished() aufgerufen")
	var player = GlobalScript.player
	
	if player and is_instance_valid(player):
		player.can_move = true
		player.can_interact = true
		print("[ESC_MENU] Nach close_mobile | can_move=", player.can_move, " can_interact=", player.can_interact)
	
	# Menü ausblenden
	menu_container.visible = false
	options_container.visible = false
	phone.visible = false
	phone_background.visible = false
	
	blinking.visible = false

	is_transitioning = false
	print("[ESC_MENU] close_menu() vollständig abgeschlossen")

# --------------------------
# Buttons
func _on_continue_pressed() -> void:
	print("[ESC_MENU] Continue gedrückt")
	close_menu()

func _on_save_pressed() -> void:
	print("Save werden später hinzugefügt.")

func _on_options_pressed() -> void:
	menu_container.visible = false
	options_container.visible = true
	print("[ESC_MENU] Options geöffnet | menu_visible=", menu_container.visible, " | options_visible=", options_container.visible)

func _on_credits_pressed() -> void:
	print("Credits werden später hinzugefügt.")

func _on_quit_pressed() -> void:
	var player_dw = GlobalScript.player_dw
	if player_dw and is_instance_valid(player_dw):
		print("[ESC_MENU] Dreamworld verlassen, zurück zur Realworld")
		get_tree().paused = false
		close_menu()
		# Zurück zur vorherigen Scene
		if GlobalScript.previous_scene != "":
			GlobalScript.change_scene(GlobalScript.previous_scene)
		else:
			print("[ESC_MENU] Keine previous_scene gefunden, lade default Realworld Scene")
			GlobalScript.change_scene("realworld_classroom_one")
	else:
		get_tree().quit()
		

# --------------------------
# PowerArea zurück
func _on_back_pressed(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		menu_container.visible = true
		options_container.visible = false
		blinking.visible = false
		print("[ESC_MENU] Zurück gedrückt | menu_visible=", menu_container.visible, " | options_visible=", options_container.visible)

# --------------------------
# Drag&Drop
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var mouse_pos = get_viewport().get_mouse_position()
			if control.get_global_rect().has_point(mouse_pos):
				dragging = true
				drag_offset = mouse_pos - control.global_position
		else:
			dragging = false

	elif event is InputEventMouseMotion and dragging:
		control.global_position = get_viewport().get_mouse_position() - drag_offset
