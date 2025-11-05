extends CanvasLayer

# ------------------------------------------------------
# Nodes
# ------------------------------------------------------
@onready var control: Control = $Control
@onready var enter_level_button: Button = $Control/EnterLevelButton
@onready var phone: Sprite2D = $Control/Phone
@onready var background: AnimatedSprite2D = $Control/PhoneScreenContainer/Background
@onready var phone_off: Sprite2D = $Control/Phone_off
@onready var power_area_off: Area2D = $Control/Phone_off/PowerArea
@onready var power_area_on: Area2D = $Control/Phone/PowerArea

var tween: Tween

# ------------------------------------------------------
# Phone State
# ------------------------------------------------------
enum PhoneState { OFF, ON }
var phone_state: PhoneState = PhoneState.OFF

# ------------------------------------------------------
# Drag & Drop Variablen
# ------------------------------------------------------
var dragging := false
var drag_offset := Vector2.ZERO

# ------------------------------------------------------
# Setup beim Levelstart
# ------------------------------------------------------
func _ready():
	control.visible = true
	enter_level_button.visible = false
	phone.visible = false
	background.visible = false
	phone_off.visible = false

	# Enter-Level-Button Setup
	enter_level_button.text = "Level One"
	enter_level_button.connect("pressed", Callable(self, "_on_enter_button_pressed"))
	enter_level_button.connect("mouse_entered", Callable(self, "_on_hover_entered"))
	enter_level_button.connect("mouse_exited", Callable(self, "_on_hover_exited"))

	# PowerAreas verbinden
	if power_area_off:
		power_area_off.connect("input_event", Callable(self, "_on_power_area_off_input"))
		power_area_off.monitoring = false
	if power_area_on:
		power_area_on.connect("input_event", Callable(self, "_on_power_area_on_input"))
		power_area_on.monitoring = false

# ------------------------------------------------------
# Drag & Drop Input (nur über Control)
# ------------------------------------------------------
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var mouse_pos = get_viewport().get_mouse_position()
			# Prüfen, ob Klick innerhalb der Control Node liegt
			if control.get_global_rect().has_point(mouse_pos):
				dragging = true
				drag_offset = mouse_pos - control.global_position
		else:
			dragging = false

	elif event is InputEventMouseMotion and dragging:
		control.global_position = get_viewport().get_mouse_position() - drag_offset

# ------------------------------------------------------
# Phone_Off anzeigen
# ------------------------------------------------------
func show_phone_off():
	phone_off.visible = true
	phone.visible = false
	background.visible = false
	enter_level_button.visible = false

	if power_area_off:
		power_area_off.monitoring = true
	if power_area_on:
		power_area_on.monitoring = false

	phone_state = PhoneState.OFF

# ------------------------------------------------------
# PowerArea Clicks
# ------------------------------------------------------
func _on_power_area_off_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_turn_on_phone()

func _on_power_area_on_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_turn_off_phone()

# ------------------------------------------------------
# Phone einschalten
# ------------------------------------------------------
func _turn_on_phone():
	phone_off.visible = false
	phone.visible = true
	background.visible = true
	enter_level_button.visible = true
	enter_level_button.modulate.a = 0.0

	if power_area_off:
		power_area_off.monitoring = false
	if power_area_on:
		power_area_on.monitoring = true

	var fade_tween = create_tween()
	phone.modulate.a = 0.0
	background.modulate.a = 0.0
	fade_tween.tween_property(phone, "modulate:a", 1.0, 0.5)
	fade_tween.tween_property(background, "modulate:a", 1.0, 0.5)
	fade_tween.tween_property(enter_level_button, "modulate:a", 1.0, 0.5)

	phone_state = PhoneState.ON

# ------------------------------------------------------
# Phone ausschalten
# ------------------------------------------------------
func _turn_off_phone():
	phone_off.visible = true
	phone.visible = false
	background.visible = false
	enter_level_button.visible = false

	if power_area_off:
		power_area_off.monitoring = true
	if power_area_on:
		power_area_on.monitoring = false

	phone_state = PhoneState.OFF

# ------------------------------------------------------
# Phone komplett ausblenden
# ------------------------------------------------------
func hide_phone():
	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(enter_level_button, "modulate:a", 0.0, 0.15)
	tween.tween_property(background, "modulate:a", 0.0, 0.15).set_delay(0.1)
	tween.tween_property(phone, "modulate:a", 0.0, 0.15).set_delay(0.2)
	tween.connect("finished", Callable(self, "_on_hide_phone_done"))

	if power_area_off:
		power_area_off.monitoring = false
	if power_area_on:
		power_area_on.monitoring = false

	phone_state = PhoneState.OFF

func _on_hide_phone_done():
	phone.visible = false
	background.visible = false
	phone_off.visible = false
	enter_level_button.visible = false

# ------------------------------------------------------
# Enter-Level-Button Fade-In/Fade-Out
# ------------------------------------------------------
func show_enter_button():
	if tween:
		tween.kill()
	tween = create_tween()
	enter_level_button.visible = true
	enter_level_button.modulate.a = 0.0
	tween.tween_property(enter_level_button, "modulate:a", 1.0, 0.5)

func hide_enter_button():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(enter_level_button, "modulate:a", 0.0, 0.3)

# ------------------------------------------------------
# LEVEL BUTTON: Levelwechsel mit Einschlafen/Aufwachen
# ------------------------------------------------------
func _on_enter_button_pressed():
	print("Level betreten!")
	enter_level_button.disabled = true

	# UI ausblenden
	var fade_tween = create_tween()
	fade_tween.tween_property(control, "modulate:a", 0.0, 0.5)
	await fade_tween.finished

	# Blink-Overlay einfügen (CanvasLayer bleibt)
	var blink_overlay_scene = preload("res://scenes/components/blink_overlay.tscn")
	if blink_overlay_scene:
		var blink_overlay_layer = blink_overlay_scene.instantiate() as CanvasLayer
		if blink_overlay_layer:
			get_tree().root.add_child(blink_overlay_layer)
			
			# Zugriff auf ColorRect, an dem das Script hängt
			var blink_rect = blink_overlay_layer.get_node("Blink_Overlay") as ColorRect
			if blink_rect:
				await blink_rect.play_sleep_wake("res://scenes/level/level_one.tscn")
			else:
				push_error("ColorRect Blink_Overlay nicht gefunden!")
		else:
			push_error("Blink overlay CanvasLayer konnte nicht instanziiert werden.")
	else:
		push_error("Blink overlay Szene konnte nicht geladen werden!")
