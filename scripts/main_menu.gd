extends Control

# --- Szenen-Referenzen ---
@onready var options: Control = $Options
@onready var title_screen: MarginContainer = $TitleScreen
@onready var blinking: Node2D = $Options/Backbutton/Blinking


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
	
	title_screen.visible = true
	options.visible = false

	# Falls ein alter Player noch existiert, kurz deaktivieren
	if GlobalScript.player and is_instance_valid(GlobalScript.player):
		GlobalScript.player.visible = false
		GlobalScript.player.can_move = false
	
	# Starte Menümusik.
	MusicManager.playMusic(MusicManager.MusicType.MENU)


# --- Neues Spiel starten ---
func _on_new_game_pressed() -> void:
	print("Starte neues Spiel - Gehe zur Hubworld")

	GlobalScript.game_first_loading = true
	GlobalScript.current_scene = "dreamworld_tutorial"
	GlobalScript.transition_scene = false
	
	# Scene wechseln → Player wird automatisch über pending_spawn in GlobalScript.spawn_player() hinzugefügt
	GlobalScript.start_new_game()


# --- Optionsmenü öffnen ---
func _on_options_pressed() -> void:
	options.visible = true
	title_screen.visible = false
	blinking.set_blinking_on(true)



# --- Spiel beenden ---
func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_continue_pressed() -> void:
	GlobalScript.game_first_loading = true
	GlobalScript.transition_scene = false
	
	GlobalScript.start_from_menu()


func _on_einstellungen_speichern_pressed() -> void:
	options.visible = false
	title_screen.visible = true


func _on_check_box_toggled(toggled_on: bool) -> void:
	GlobalScript.tutorial_on = toggled_on
	blinking.enable_tutorial(toggled_on)
