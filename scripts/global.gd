extends Node
class_name Global

# -------------------------
# Allgemeine Szenen-Infos
# -------------------------
var current_scene: String = "realworld_classroom_one"
var next_scene: String = ""
var transition_scene: bool = false
var pending_spawn: bool = false 

# -------------------------
# Spieler-Infos
# -------------------------
var player_positions := {
	"realworld_classroom_one": Vector2(504, 340),
	"realworld_hall": Vector2(568, 374)
}

var player: Node = null
var game_first_loading: bool = true

# -------------------------
# Neues Spiel starten
# -------------------------
func start_new_game() -> void:
	pending_spawn = true
	get_tree().change_scene_to_file("res://scenes/realworld_classroom_one.tscn")


# -------------------------
# Spieler instanziieren + unter YSort packen
# -------------------------
func spawn_player() -> void:
	if player != null and is_instance_valid(player):
		return  # Player existiert schon

	var player_scene = load("res://scenes/player_realworld.tscn")
	player = player_scene.instantiate()

	var current_scene_node = get_tree().current_scene
	current_scene_node.add_child(player)
	player.z_index = 2
	player.scale = Vector2(1.5, 1.5)
	player.visible = true
	player.can_move = true

	if player_positions.has(current_scene):
		player.global_position = player_positions[current_scene]
	else:
		player.global_position = Vector2(504, 340)  # Fallback

# -------------------------
# Player mit Szene wechseln
# -------------------------
func move_player_to_current_scene() -> void:
	if player == null or not is_instance_valid(player):
		spawn_player()
	else:
		# Falls Player schon existiert, aber nicht in der aktuellen Szene
		if player.get_parent() != get_tree().current_scene:
			player.get_parent().remove_child(player)
			get_tree().current_scene.add_child(player)
			player.visible = true
			player.can_move = true

# -------------------------
# Szene wechseln
# -------------------------
func change_scene(new_scene: String) -> void:
	# Alte Szene entfernen
	var old_scene = get_tree().current_scene
	if old_scene:
		old_scene.queue_free()

	# Neue Szene laden
	var scene_path := "res://scenes/%s.tscn" % new_scene
	var new_scene_instance = load(scene_path).instantiate()
	get_tree().root.add_child(new_scene_instance)
	get_tree().current_scene = new_scene_instance  # richtig setzen

	current_scene = new_scene

	# Player verschieben
	move_player_to_current_scene()

	# Spieler sichtbar & aktiv
	if player:
		player.visible = true
		player.can_move = true
