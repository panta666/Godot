extends Node2D

var level_ui: CanvasLayer

# Spawn Position von Classroom_One -> Hall
const PLAYER_SPAWN_POS := Vector2(144, 67)

func _ready() -> void:
	# --- Player sicher in die aktuelle Szene verschieben oder neu spawnen ---
	GlobalScript.move_player_to_current_scene()

	# --- Player direkt an die Tür setzen ---
	if GlobalScript.player:
		GlobalScript.player.global_position = PLAYER_SPAWN_POS
		GlobalScript.player.visible = true
		GlobalScript.player.can_move = true
		print("Player in Hall an Tür positioniert: ", GlobalScript.player.global_position)

	# Spielerposition beim ersten Laden setzen (nur optional, falls du andere Logik brauchst)
	if GlobalScript.game_first_loading:
		GlobalScript.game_first_loading = false

	# --- Level UI laden oder wiederherstellen ---
	if not level_ui:
		var ui_scene = load("res://scenes/level_ui.tscn")
		level_ui = ui_scene.instantiate()
		add_child(level_ui)
		print("Level UI wurde geladen")
	elif not level_ui.is_inside_tree():
		add_child(level_ui)
		print("Level UI wiederhergestellt")

	level_ui.hide_enter_button()


func _process(_delta: float) -> void:
	_change_scene_if_needed()


func _change_scene_if_needed() -> void:
	if GlobalScript.transition_scene:
		# Spielerposition vorher speichern
		if GlobalScript.player:
			GlobalScript.player_positions["realworld_hall"] = GlobalScript.player.global_position

		# Szene wechseln
		GlobalScript.change_scene("realworld_classroom_one")

		# Player direkt in neue Szene verschieben
		GlobalScript.move_player_to_current_scene()

		GlobalScript.transition_scene = false


# --- Tür-Kollisionssignale ---
func _on_classroom_one_door_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		GlobalScript.transition_scene = true

func _on_classroom_one_door_body_exited(body: Node2D) -> void:
	if body == GlobalScript.player:
		GlobalScript.transition_scene = false
