extends Node
class_name Global

# -------------------------
# Allgemeine Szenen-Infos
# -------------------------
var current_scene: String = "realworld_classroom_one"
var previous_scene: String = ""
var next_scene: String = ""
var transition_scene: bool = false
var pending_spawn: bool = false

# -------------------------
# Spieler-Infos
# -------------------------
var player_positions := {
	"realworld_classroom_one": Vector2(504, 340),
	"realworld_classroom_two": Vector2(1140, 691),
	"realworld_hall": Vector2(567, 416)
}

var player: Node = null

var game_first_loading: bool = true

const AUDIO_BUSES = ['Master', 'Music', 'SFX']

# -------------------------
# Neues Spiel starten
# -------------------------
func start_new_game() -> void:
	pending_spawn = true
	current_scene = "realworld_classroom_one"
	previous_scene = ""
	
	# Scene wechseln - Player wird erst nach SceneReady erzeugt
	get_tree().change_scene_to_file("res://scenes/realworld_classroom_one.tscn")
	
	# Player deferred instanziieren
	call_deferred("spawn_player")


# -------------------------
# Spieler instanziieren + unter Szene packen
# -------------------------
func spawn_player() -> void:
	if player != null and is_instance_valid(player):
		return

	var player_scene = load("res://scenes/player_realworld.tscn")
	if not player_scene:
		push_error("player_realworld.tscn konnte nicht geladen werden!")
		return

	player = player_scene.instantiate()

	var current_scene_node = get_tree().current_scene
	if not current_scene_node:
		push_error("Kein current_scene beim spawn_player() vorhanden!")
		return

	current_scene_node.add_child(player)
	player.z_index = 2
	player.scale = Vector2(1.5, 1.5)
	player.visible = true

	# Bewegung aktivieren
	if player.has_method("set_can_move"):
		player.call_deferred("set_can_move", true)
	elif player.has_variable("can_move"):
		player.set("can_move", true)

	# Position setzen
	if player_positions.has(current_scene):
		player.global_position = player_positions[current_scene]
	else:
		player.global_position = Vector2(504, 340)

	# Animation deferred starten
	call_deferred("_deferred_play_default_animation")


# -------------------------
# Player in aktuelle Szene verschieben
# -------------------------
func move_player_to_current_scene() -> void:
	if player == null or not is_instance_valid(player):
		spawn_player()
	else:
		if player.get_parent() != get_tree().current_scene:
			player.get_parent().remove_child(player)
			get_tree().current_scene.add_child(player)
			call_deferred("_deferred_setup_player")


# -------------------------
# Deferred Setup Player
# -------------------------
func _deferred_setup_player() -> void:
	if not player:
		return
	player.visible = true
	if player.has_method("set_can_move"):
		player.call_deferred("set_can_move", true)
	elif player.has_variable("can_move"):
		player.set("can_move", true)
	call_deferred("_deferred_play_default_animation")


# -------------------------
# Deferred: Default-Animation sicher spielen
# -------------------------
func _deferred_play_default_animation() -> void:
	call_deferred("_play_default_animation")


func _play_default_animation() -> void:
	if not player or not is_instance_valid(player):
		return

	var anim_sprite := _find_animated_sprite(player)
	if anim_sprite == null:
		print("Kein AnimatedSprite2D im Player gefunden.")
		return
	if anim_sprite.sprite_frames == null:
		print("AnimatedSprite2D hat keine sprite_frames-Resource.")
		return

	var preferred_anim := "idle_down"
	if player.has_variable("facing_direction"):
		var fd = str(player.get("facing_direction"))
		if fd != "":
			var candidate = "idle_%s" % fd
			if anim_sprite.sprite_frames.has_animation(candidate):
				preferred_anim = candidate

	# Safe Animation spielen
	if anim_sprite.sprite_frames.has_animation(preferred_anim):
		anim_sprite.play(preferred_anim)
	else:
		var anim_list = anim_sprite.sprite_frames.get_animation_names()
		if anim_list.size() > 0:
			anim_sprite.play(anim_list[0])
			print("Preferred animation '%s' nicht gefunden — spiele '%s'." % [preferred_anim, anim_list[0]])
		else:
			print("Keine Animationen in sprite_frames vorhanden.")


# -------------------------
# Hilfsfunktion: rekursives Finden eines AnimatedSprite2D-Knotens
# -------------------------
func _find_animated_sprite(node: Node) -> AnimatedSprite2D:
	if node is AnimatedSprite2D:
		return node
	for child in node.get_children():
		if child is Node:
			var found := _find_animated_sprite(child)
			if found != null:
				return found
	return null


# -------------------------
# Szene wechseln
# -------------------------
func change_scene(new_scene: String) -> void:
	transition_scene = false

	var dialogic_node = get_tree().root.get_node_or_null("DialogicLayout_VisualNovelStyle")
	if dialogic_node:
		dialogic_node.queue_free()

	var old_scene = get_tree().current_scene
	if old_scene:
		old_scene.queue_free()

	var scene_path := "res://scenes/%s.tscn" % new_scene
	var new_scene_instance = load(scene_path).instantiate()
	get_tree().root.add_child(new_scene_instance)
	get_tree().current_scene = new_scene_instance

	previous_scene = current_scene
	current_scene = new_scene

	move_player_to_current_scene()


# ==========================================================
#                     ESC-MENÜ SYSTEM
# ==========================================================
var esc_menu_scene := preload("res://scenes/esc_menu.tscn")
var esc_menu_instance: CanvasLayer = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc_menu"):
		var _player = GlobalScript.player
		if not _player:
			print("[ESC_MENU] Kein Player gefunden")
			return
		if _player.is_busy:
			return
		else:
			_toggle_esc_menu()

func _toggle_esc_menu() -> void:
	if get_tree().current_scene and get_tree().current_scene.name == "MainMenu":
		return

	if not esc_menu_instance:
		esc_menu_instance = esc_menu_scene.instantiate()
		get_tree().root.add_child(esc_menu_instance)
		esc_menu_instance.open_menu()
	else:
		if esc_menu_instance.visible:
			esc_menu_instance.close_menu()
		else:
			esc_menu_instance.open_menu()
