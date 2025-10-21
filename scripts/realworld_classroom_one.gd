extends Node2D

var level_ui

func _ready() -> void:
	# --- Spielerposition festlegen ---
	if global.game_first_loading == true:
		$Player_Realworld.position.x = global.player_start_posX
		$Player_Realworld.position.y = global.player_start_posY
	else:
		$Player_Realworld.position.x = global.player_exit_door_posX
		$Player_Realworld.position.y = global.player_exit_door_posY

	# --- UI laden, falls noch nicht vorhanden ---
	if level_ui == null:
		var ui_scene = load("res://scenes/level_ui.tscn")
		level_ui = ui_scene.instantiate()
		add_child(level_ui)
		print("Level UI wurde geladen")
	else:
		# Sicherstellen, dass es auch aktiv ist (wird beim Szenenwechsel beibehalten)
		if not level_ui.is_inside_tree():
			add_child(level_ui)
			print("Level UI wiederhergestellt")

	# Zu Beginn ausblenden
	level_ui.hide_enter_button()

func _process(_delta: float) -> void:
	changeScene()


func changeScene():
	if global.transition_scene == true:
		if global.current_scene == 'realworld_classroom_one':
			get_tree().change_scene_to_file("res://scenes/realworld_hall.tscn")
			global.game_first_loading = false
			global.finish_change_scene()


func _on_door_exit_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = true


func _on_door_exit_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = false
