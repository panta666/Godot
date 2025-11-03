extends Node2D

var level_ui
const PLAYER_SPAWN_POS_FROM_HALL := Vector2(568, 362)  # Position, wenn Player aus Hall kommt

func _ready() -> void:
	MusicManager.playMusic(MusicManager.MusicType.HUB)
	print("Classroom Szene geladen")

	# --- Player sicherstellen ---
	if not GlobalScript.player or not is_instance_valid(GlobalScript.player):
		var player_scene = load("res://scenes/player_realworld.tscn")
		GlobalScript.player = player_scene.instantiate()
		get_tree().current_scene.add_child(GlobalScript.player)
		print("Player wurde von classroom.gd neu hinzugefügt")
	elif GlobalScript.player.get_parent() != self:
		GlobalScript.player.get_parent().remove_child(GlobalScript.player)
		add_child(GlobalScript.player)
		print("Vorhandene Player-Instanz zur Szene hinzugefügt")

	# --- Spielerposition setzen ---
	if GlobalScript.current_scene == "realworld_hall":
		# Player kommt aus Hall → feste Position und Blick nach oben
		GlobalScript.player.global_position = PLAYER_SPAWN_POS_FROM_HALL
		GlobalScript.player.facing_direction = "up"
		GlobalScript.player.animated_sprite_2d.play("idle_up")
	else:
		# Standardposition beim ersten Laden
		var default_pos := Vector2(504, 340)
		if GlobalScript.player_positions.has("realworld_classroom_one"):
			GlobalScript.player.global_position = GlobalScript.player_positions["realworld_classroom_one"]
		else:
			GlobalScript.player.global_position = default_pos

	# --- Sichtbarkeit & Steuerung aktivieren ---
	GlobalScript.player.visible = true
	GlobalScript.player.can_move = true

	print("Player in classroom positioniert bei:", GlobalScript.player.global_position)

	# --- UI laden oder wiederherstellen ---
	if not level_ui:
		var ui_scene = load("res://scenes/level_ui.tscn")
		level_ui = ui_scene.instantiate()
		add_child(level_ui)
		print("Level UI wurde geladen")
	elif not level_ui.is_inside_tree():
		add_child(level_ui)
		print("Level UI wiederhergestellt")

	# Enter-Button zu Beginn ausblenden
	level_ui.hide_enter_button()


func _process(_delta: float) -> void:
	if GlobalScript.transition_scene:
		GlobalScript.transition_scene = false  # Mehrfachwechsel verhindern
		await get_tree().process_frame
		_change_scene_to_next()


func _change_scene_to_next() -> void:
	print("Wechsle Szene von Classroom → Hall")
	GlobalScript.current_scene = "realworld_hall"
	GlobalScript.change_scene("realworld_hall")


# --- Tür-Kollisionssignale ---
func _on_door_exit_body_entered(body: Node2D) -> void:
	if GlobalScript.player and body == GlobalScript.player:
		GlobalScript.transition_scene = true


func _on_door_exit_body_exited(body: Node2D) -> void:
	if GlobalScript.player and body == GlobalScript.player:
		GlobalScript.transition_scene = false
