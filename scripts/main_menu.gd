extends Control

# --- Szenen-Referenzen ---
var OPTIONS_SCENE := preload("res://scenes/Options.tscn")

# --- Laufzeit-Referenzen ---
var options_instance: Control = null

# --- Menü-Kamera ---
@onready var menu_camera: Camera2D = $Camera2D


func _ready() -> void:
	# Menü-Kamera aktivieren
	if menu_camera and menu_camera is Camera2D:
		menu_camera.make_current()
	else:
		push_warning("MainMenu hat keine gültige Camera2D!")

	# Falls ein alter Player noch existiert, kurz deaktivieren
	if GlobalScript.player and is_instance_valid(GlobalScript.player):
		GlobalScript.player.visible = false
		GlobalScript.player.can_move = false


# --- Neues Spiel starten ---
func _on_new_game_pressed() -> void:
	print("Starte neues Spiel - Gehe zur Hubworld")

	GlobalScript.game_first_loading = true
	GlobalScript.current_scene = "realworld_classroom_one"
	GlobalScript.transition_scene = false

	# Scene wechseln - Player wird automatisch über pending_spawn in GlobalScript.spawn_player() hinzugefügt
	GlobalScript.start_new_game()


# --- Optionsmenü öffnen ---
func _on_options_pressed() -> void:
	if options_instance == null:
		options_instance = OPTIONS_SCENE.instantiate()
		add_child(options_instance)

		if options_instance.has_signal("closed"):
			options_instance.closed.connect(_on_options_closed)


# --- Optionsmenü schließen ---
func _on_options_closed() -> void:
	if options_instance:
		options_instance.queue_free()
		options_instance = null


# --- Spiel beenden ---
func _on_quit_pressed() -> void:
	get_tree().quit()
