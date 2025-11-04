extends CanvasLayer

@onready var control: Control = $Control
@onready var enter_level_button: Button = $Control/EnterLevelButton
@onready var phone: Sprite2D = $Control/Phone
@onready var background: AnimatedSprite2D = $Control/PhoneScreenContainer/Background

var tween: Tween

func _ready():
	control.visible = true
	enter_level_button.visible = false
	phone.visible = false
	background.visible = false
	enter_level_button.text = "Level One"
	enter_level_button.connect("pressed", Callable(self, "_on_enter_button_pressed"))
	enter_level_button.connect("mouse_entered", Callable(self, "_on_hover_entered"))
	enter_level_button.connect("mouse_exited", Callable(self, "_on_hover_exited"))

# ------------------------------------------------------
# Sanft einblenden
# ------------------------------------------------------
func show_enter_button():
	if tween:
		tween.kill()
	tween = create_tween()
	enter_level_button.visible = true
	phone.visible = true
	background.visible = true
	enter_level_button.modulate.a = 0.0
	tween.tween_property(enter_level_button, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# Sanft ausblenden
func hide_enter_button():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(enter_level_button, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	enter_level_button.visible = false
	phone.visible = false
	background.visible = false

# ------------------------------------------------------
# Interaktionen
# ------------------------------------------------------
func _on_hover_entered():
	var hover_tween = create_tween()
	hover_tween.tween_property(enter_level_button, "scale", Vector2(1.05, 1.05), 0.15)

func _on_hover_exited():
	var exit_tween = create_tween()
	exit_tween.tween_property(enter_level_button, "scale", Vector2(1, 1), 0.15)

func _on_enter_button_pressed():
	print("Level betreten!")
	enter_level_button.disabled = true
	var fade_tween = create_tween()
	fade_tween.tween_property(control, "modulate:a", 0.0, 0.5)
	await fade_tween.finished
	get_tree().change_scene_to_file("res://scenes/level/level_one.tscn")
