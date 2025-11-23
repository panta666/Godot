extends CanvasLayer

# ------------------------------------------------------
# Nodes
# ------------------------------------------------------
@onready var control: Control = $Control

@onready var enter_level_button: Button = $Control/EnterLevelButton
@onready var enter_level_button2: Button = $Control/EnterLevelButton2
@onready var enter_level_button3: Button = $Control/EnterLevelButton3

@onready var phone: Sprite2D = $Control/Phone
@onready var background: AnimatedSprite2D = $Control/PhoneScreenContainer/Background
@onready var phone_off: Sprite2D = $Control/Phone_off
@onready var power_area_off: Area2D = $Control/Phone_off/PowerArea
@onready var power_area_on: Area2D = $Control/Phone/PowerArea

# Tutorial
@onready var blinking: Node2D = $Control/Blinking


var tween: Tween

# ------------------------------------------------------
# Phone State
# ------------------------------------------------------
enum PhoneState { OFF, ON }
var phone_state: PhoneState = PhoneState.OFF

# ------------------------------------------------------
# Level Freischaltungen
# ------------------------------------------------------
@export var current_room: String = "OOP"

var oop_level_unlocked := [true, false, false]
var medg_level_unlocked := [false, false, false]

# ------------------------------------------------------
# Drag & Drop
# ------------------------------------------------------
var dragging := false
var drag_offset := Vector2.ZERO


# ======================================================
# READY
# ======================================================
func _ready():
	control.visible = true
	phone.visible = false
	background.visible = false
	phone_off.visible = false
	
	blinking.visible = false

	# Unlock-Arrays aus Global übernehmen
	oop_level_unlocked = GlobalScript.oop_level_unlocked.duplicate()
	medg_level_unlocked = GlobalScript.medg_level_unlocked.duplicate()

	# Buttons verbinden
	enter_level_button.connect("pressed", Callable(self, "_on_enter_level1_pressed"))
	enter_level_button2.connect("pressed", Callable(self, "_on_enter_level2_pressed"))
	enter_level_button3.connect("pressed", Callable(self, "_on_enter_level3_pressed"))

	# Power Buttons
	if power_area_off:
		power_area_off.connect("input_event", Callable(self, "_on_power_area_off_input"))
		power_area_off.monitoring = false

	if power_area_on:
		power_area_on.connect("input_event", Callable(self, "_on_power_area_on_input"))
		power_area_on.monitoring = false


# ======================================================
# DRAG UI
# ======================================================
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


# ======================================================
# LEVEL BUTTON UPDATE
# ======================================================
func update_level_button():
	if current_room == "OOP":
		_update_oop_buttons()
	elif current_room == "MEDG":
		_update_medg_buttons()


func _update_oop_buttons():
	enter_level_button.visible = oop_level_unlocked[0]
	enter_level_button.disabled = not oop_level_unlocked[0]
	enter_level_button.text = "OOP Level 1"

	enter_level_button2.visible = oop_level_unlocked[1]
	enter_level_button2.disabled = not oop_level_unlocked[1]
	enter_level_button2.text = "OOP Level 2"

	enter_level_button3.visible = oop_level_unlocked[2]
	enter_level_button3.disabled = not oop_level_unlocked[2]
	enter_level_button3.text = "OOP Level 3"


func _update_medg_buttons():
	enter_level_button.visible = medg_level_unlocked[0]
	enter_level_button.disabled = not medg_level_unlocked[0]
	enter_level_button.text = "MEDG Level 1"

	enter_level_button2.visible = medg_level_unlocked[1]
	enter_level_button2.disabled = not medg_level_unlocked[1]
	enter_level_button2.text = "MEDG Level 2"

	enter_level_button3.visible = medg_level_unlocked[2]
	enter_level_button3.disabled = not medg_level_unlocked[2]
	enter_level_button3.text = "MEDG Level 3"


# ======================================================
# PHONE EVENTS
# ======================================================
func show_phone_off():
	phone_off.visible = true
	phone.visible = false
	background.visible = false

	enter_level_button.visible = false
	enter_level_button2.visible = false
	enter_level_button3.visible = false

	power_area_off.monitoring = true
	power_area_on.monitoring = false

	phone_state = PhoneState.OFF
	
	blinking.visible = true


func _on_power_area_off_input(_vp, event, _idx):
	if event is InputEventMouseButton and event.pressed:
		_turn_on_phone()


func _on_power_area_on_input(_vp, event, _idx):
	if event is InputEventMouseButton and event.pressed:
		_turn_off_phone()


func _turn_on_phone():
	phone_off.visible = false
	phone.visible = true
	background.visible = true
	
	blinking.visible = false

	update_level_button()

	# Fade animation
	phone.modulate.a = 0.0
	background.modulate.a = 0.0

	var fade_tween = create_tween()
	fade_tween.tween_property(phone, "modulate:a", 1.0, 0.5)
	fade_tween.tween_property(background, "modulate:a", 1.0, 0.5)

	power_area_off.monitoring = false
	power_area_on.monitoring = true

	phone_state = PhoneState.ON


func _turn_off_phone():
	phone_off.visible = true
	phone.visible = false
	background.visible = false

	enter_level_button.visible = false
	enter_level_button2.visible = false
	enter_level_button3.visible = false

	power_area_off.monitoring = true
	power_area_on.monitoring = false

	phone_state = PhoneState.OFF


# ======================================================
# LEVEL LADEN – Buttons
# ======================================================
func _on_enter_level1_pressed():
	_load_level_scene(_get_scene_path(0))


func _on_enter_level2_pressed():
	_load_level_scene(_get_scene_path(1))


func _on_enter_level3_pressed():
	_load_level_scene(_get_scene_path(2))


func _get_scene_path(level_index: int) -> String:
	if current_room == "OOP": 
		return [
			"res://scenes/level/oop/oop_level_one.tscn",
			"res://scenes/level/oop/oop_level_two.tscn",
			"res://scenes/level/oop/oop_level_three.tscn"
		][level_index]

	if current_room == "MEDG":
		return [
			"res://scenes/level/medg/medg_level_one.tscn",
			"res://scenes/level/medg/medg_level_two.tscn",
			"res://scenes/level/medg/medg_level_three.tscn"
		][level_index]

	return ""

func hide_phone():
	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(enter_level_button, "modulate:a", 0.0, 0.15)
	tween.tween_property(background, "modulate:a", 0.0, 0.15)
	tween.tween_property(phone, "modulate:a", 0.0, 0.15)

	tween.connect("finished", Callable(self, "_on_hide_phone_done"))

	power_area_off.monitoring = false
	power_area_on.monitoring = false

	phone_state = PhoneState.OFF

func hide_enter_button():
	enter_level_button.visible = false
	enter_level_button2.visible = false
	enter_level_button3.visible = false

# Gemeinsames Laden mit Blink-Effekt
func _load_level_scene(target_scene: String):
	if target_scene == "":
		return

	MusicManager.playMusic(MusicManager.MusicType.NONE)

	enter_level_button.disabled = true
	enter_level_button2.disabled = true
	enter_level_button3.disabled = true

	var fade_tween = create_tween()
	fade_tween.tween_property(control, "modulate:a", 0.0, 0.5)
	await fade_tween.finished

	var blink_overlay = preload("res://scenes/components/blink_overlay.tscn").instantiate()
	get_tree().root.add_child(blink_overlay)

	var blink_rect = blink_overlay.get_node("Blink_Overlay")
	await blink_rect.play_sleep_wake(target_scene)
