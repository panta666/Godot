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

# ------------------------------------------------------
# Drag & Drop Variablen
# ------------------------------------------------------
var dragging := false
var drag_offset := Vector2.ZERO

# ------------------------------------------------------
func _ready() -> void:
	# Buttons verbinden
	continue_button.pressed.connect(_on_continue_pressed)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	options_button.pressed.connect(_on_options_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Audio-Slider verbinden
	master_volume.value_changed.connect(_on_master_volume_value_changed)
	music_volume.value_changed.connect(_on_music_volume_value_changed)
	check_box.toggled.connect(_on_check_box_toggled)

	# PowerArea zurück-Button
	back.input_event.connect(_on_back_pressed)

	# Menü standardmäßig geschlossen
	menu_container.visible = false
	options_container.visible = false
	phone.visible = false
	phone_background.visible = false

	# Input aktivieren
	set_process_input(true)

# --------------------------------------------------------
# Drag&Drop Input (nur Maus)
func _input(event: InputEvent) -> void:
	# Linksklick gedrückt -> Drag starten
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var mouse_pos = get_viewport().get_mouse_position()
			if control.get_global_rect().has_point(mouse_pos):
				dragging = true
				drag_offset = mouse_pos - control.global_position
		else:
			dragging = false
	# Mausbewegung -> Drag ausführen
	elif event is InputEventMouseMotion and dragging:
		control.global_position = get_viewport().get_mouse_position() - drag_offset

# --------------------------------------------------------
# ESC-Taste abfangen (immer, unabhängig von Drag)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("esc_menu"):
		if menu_container.visible or options_container.visible:
			close_menu()
		else:
			open_menu()

# --------------------------------------------------------
# Menü öffnen / schließen
func open_menu() -> void:
	menu_container.visible = true
	options_container.visible = false
	phone.visible = true
	phone_background.visible = true

	var player = GlobalScript.player
	if player:
		player.can_move = false

func close_menu() -> void:
	menu_container.visible = false
	options_container.visible = false
	phone.visible = false
	phone_background.visible = false

	var player = GlobalScript.player
	if player:
		player.can_move = true

# --------------------------------------------------------
# Button-Aktionen
func _on_continue_pressed() -> void:
	close_menu()
	
func _on_save_pressed() -> void:
	print("Save werden später hinzugefügt.")
	
func _on_load_pressed() -> void:
	print("Load werden später hinzugefügt.")		

func _on_options_pressed() -> void:
	menu_container.visible = false
	options_container.visible = true

func _on_credits_pressed() -> void:
	print("Credits werden später hinzugefügt.")

func _on_quit_pressed() -> void:
	get_tree().quit()

# --------------------------------------------------------
# PowerArea zurück-Button im Optionsmenu
func _on_back_pressed(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		menu_container.visible = true
		options_container.visible = false

# --------------------------------------------------------
# Audio-Optionen
func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MASTER_BUS, value)

func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS, value)

func _on_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(MASTER_BUS, toggled_on)
