extends CanvasLayer

# --- Onready-Referenzen ---
@onready var control: Control = $Control
@onready var menu_container: VBoxContainer = $Control/MenuContainer
@onready var menu_options: VBoxContainer = $Control/MenuContainer/MenuOptions
@onready var options_container: CenterContainer = $Control/OptionsContainer
@onready var v_box_container: VBoxContainer = $Control/OptionsContainer/VBoxContainer

# --- Menü-Buttons ---
@onready var continue_button: Button = $Control/MenuContainer/MenuOptions/Continue
@onready var save_button: Button = $Control/MenuContainer/MenuOptions/Save
@onready var load_button: Button = $Control/MenuContainer/MenuOptions/Load
@onready var options_button: Button = $Control/MenuContainer/MenuOptions/Options
@onready var credits_button: Button = $Control/MenuContainer/MenuOptions/Credits
@onready var quit_button: Button = $Control/MenuContainer/MenuOptions/Quit

# --- Options-UI ---
@onready var master_volume: HSlider = $Control/OptionsContainer/VBoxContainer/MasterVolume
@onready var check_box: CheckBox = $Control/OptionsContainer/VBoxContainer/CheckBox
@onready var music_volume: HSlider = $Control/OptionsContainer/VBoxContainer/MusicVolume

# --- Phone / PowerArea ---
@onready var phone: Sprite2D = $Control/Phone
@onready var phone_background: AnimatedSprite2D = $Control/PhoneScreenContainer/Background
@onready var back: Area2D = $Control/Phone/PowerArea

# --- Soundbus-IDs ---
const MASTER_BUS := 0
const MUSIC_BUS := 1

# --------------------------
# Drag & Drop
var dragging := false
var drag_offset := Vector2.ZERO

# --------------------------
# Menü-Status
var is_transitioning: bool = false

func _ready() -> void:
	GlobalScript.esc_menu_instance = self

	# Buttons verbinden
	continue_button.pressed.connect(_on_continue_pressed)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	options_button.pressed.connect(_on_options_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	master_volume.value_changed.connect(_on_master_volume_value_changed)
	music_volume.value_changed.connect(_on_music_volume_value_changed)
	check_box.toggled.connect(_on_check_box_toggled)

	back.input_event.connect(_on_back_pressed)

	# Menü unsichtbar starten
	menu_container.visible = false
	options_container.visible = false
	phone.visible = false
	phone_background.visible = false

	set_process_input(true)

# --------------------------
# ESC-Taste
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("esc_menu"):
		var player = GlobalScript.player
		if not player:
			print("[ESC_MENU] Kein Player gefunden")
			return

		# Prüfen, ob Player beschäftigt ist oder Menü-Transition aktiv
		if is_transitioning or player.is_busy:
			print("[ESC_MENU] ESC blockiert | is_transitioning=", is_transitioning, 
				  " | player.is_busy=", player.is_busy,
				  " | can_move=", player.can_move, 
				  " | can_interact=", player.can_interact)
			return

		print("[ESC_MENU] ESC gedrückt | Menü wird geöffnet/geschlossen")
		if menu_container.visible or options_container.visible:
			close_menu()
		else:
			open_menu()

# --------------------------
# Menü öffnen
func open_menu() -> void:
	if is_transitioning:
		print("[ESC_MENU] open_menu() abgebrochen, is_transitioning=true")
		return
	print("[ESC_MENU] open_menu() gestartet")
	is_transitioning = true

	var player = GlobalScript.player
	if not player:
		print("[ESC_MENU] Kein Player gefunden beim Öffnen")
		is_transitioning = false
		return

	player.can_move = false
	player.can_interact = false
	print("[ESC_MENU] Player blockiert | can_move=", player.can_move, " | can_interact=", player.can_interact)

	# Menü sichtbar machen
	menu_container.visible = true
	options_container.visible = false
	phone.visible = true
	phone_background.visible = true
	
	print("[ESC_MENU] Vor open_mobile | can_move=", player.can_move, " can_interact=", player.can_interact)
	player.open_mobile(Callable(self, "_on_open_mobile_finished"))

func _on_open_mobile_finished() -> void:
	print("[ESC_MENU] _on_open_mobile_finished() aufgerufen")
	is_transitioning = false

	var player = GlobalScript.player
	if player:
		print("[ESC_MENU] Nach open_mobile | can_move=", player.can_move, " can_interact=", player.can_interact)

# --------------------------
# Menü schließen
func close_menu() -> void:
	if is_transitioning:
		print("[ESC_MENU] close_menu() abgebrochen, is_transitioning=true")
		return
	print("[ESC_MENU] close_menu() gestartet")
	is_transitioning = true

	var player = GlobalScript.player
	if not player:
		print("[ESC_MENU] Kein Player gefunden beim Schließen")
		is_transitioning = false
		return

	print("[ESC_MENU] Vor close_mobile | can_move=", player.can_move, " can_interact=", player.can_interact)
	player.close_mobile(Callable(self, "_on_close_mobile_finished"))
	is_transitioning = false

func _on_close_mobile_finished() -> void:
	print("[ESC_MENU] _on_close_mobile_finished() aufgerufen")
	var player = GlobalScript.player
	if player:
		player.can_move = true
		player.can_interact = true
		print("[ESC_MENU] Nach close_mobile | can_move=", player.can_move, " can_interact=", player.can_interact)
		
	# Menü ausblenden
	menu_container.visible = false
	options_container.visible = false
	phone.visible = false
	phone_background.visible = false

	is_transitioning = false
	print("[ESC_MENU] close_menu() vollständig abgeschlossen")

# --------------------------
# Buttons
func _on_continue_pressed() -> void:
	print("[ESC_MENU] Continue gedrückt")
	close_menu()

func _on_save_pressed() -> void:
	print("Save werden später hinzugefügt.")

func _on_load_pressed() -> void:
	print("Load werden später hinzugefügt.")

func _on_options_pressed() -> void:
	menu_container.visible = false
	options_container.visible = true
	print("[ESC_MENU] Options geöffnet | menu_visible=", menu_container.visible, " | options_visible=", options_container.visible)

func _on_credits_pressed() -> void:
	print("Credits werden später hinzugefügt.")

func _on_quit_pressed() -> void:
	get_tree().quit()

# --------------------------
# PowerArea zurück
func _on_back_pressed(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		menu_container.visible = true
		options_container.visible = false
		print("[ESC_MENU] Zurück gedrückt | menu_visible=", menu_container.visible, " | options_visible=", options_container.visible)

# --------------------------
# Audio
func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MASTER_BUS, value)

func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS, value)

func _on_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(MASTER_BUS, toggled_on)
