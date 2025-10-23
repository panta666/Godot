extends Control

# Const für Optionsmenü. Lädt das Optionsmenu um es später anzuzeigen.
var OPTIONS_SCENE = preload("res://scenes/Options.tscn")
# Instanz für das Optionsmenu.
var options_instance = null

# Methode wird aufgerufen wenn auf der UI der New Game Button angeklickt wird.
func _on_new_game_pressed() -> void:
	print("Das Spiel soll starten. Gehe zur Hubworld.")
	# Spielfortschritt zurücksetzen (für später, wenn wir Savegames haben)
	global.game_first_loading = true
	global.current_scene = "realworld_classroom_one"
	global.transition_scene = false

	# Szene wechseln zur Hubworld.
	get_tree().change_scene_to_file("res://scenes/realworld_classroom_one.tscn")

# Methode wird aufgerufen wenn auf der UI der Options Button angeklickt wird.
func _on_options_pressed() -> void:
	# Wenn keine Instanz des Optionsmenu existiert wird sie erstellt und als Kind dem Haupmenü
	# hinzugefügt.
	if options_instance == null:
		options_instance = OPTIONS_SCENE.instantiate()
		add_child(options_instance)
		
		# Prüft ob die Options Szene ein Signal closed hat, welche das schließen der Szene steuert.
		if options_instance.has_signal("closed"):
			print("options_instance.closed.connect(_on_options_closed)")

# Methde um das Spiel zu beenden wenn der Quit Buttn auf der UI gedrückt wird.
func _on_quit_pressed() -> void:
	get_tree().quit()
