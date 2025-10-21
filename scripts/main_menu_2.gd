extends Control

var OPTIONS_SCENE = preload("res://scenes/Options.tscn")

var options_instance = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_new_game_pressed() -> void:
	print("Das Spiel soll starten. Gehe zur Hubworld.")
	# Spielfortschritt zurücksetzen (für später, wenn wir Savegames haben)
	global.game_first_loading = true
	global.current_scene = "realworld_classroom_one"
	global.transition_scene = false

	# Szene wechseln
	get_tree().change_scene_to_file("res://scenes/realworld_classroom_one.tscn")


func _on_options_pressed() -> void:
	if options_instance == null:
		options_instance = OPTIONS_SCENE.instantiate()
		add_child(options_instance)
		
		if options_instance.has_signal("closed"):
			print("options_instance.closed.connect(_on_options_closed)")


func _on_quit_pressed() -> void:
	get_tree().quit()
