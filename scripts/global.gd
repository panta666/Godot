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
var last_door_for_transition: Node = null

# -------------------------
# Spieler-Infos
# -------------------------
var player_positions := {
	"realworld_classroom_one": Vector2(504, 340),
	"realworld_classroom_two": Vector2(1140, 691),
	"realworld_hall": Vector2(567, 416),
	"realworld_home": Vector2(368, 170)
}

var player: Node = null

var game_first_loading: bool = true

const AUDIO_BUSES = ['Master', 'Music', 'SFX']

# -------------------------
# Freigeschaltete Level (global)
# -------------------------
var oop_level_unlocked := [true, false, false]
var medg_level_unlocked := [false, false, false]

# -------------------------
# Tutorial steurung (global)
# -------------------------
var tutorial_on := true

# -------------------------
# Signals (global)
# -------------------------
signal tutorial_toggled(is_enabled: bool)

# -------------------------
# Possible Resolutions for the Game (global)
# -------------------------
var resolutions = {
	"3840x2160": Vector2i(3840, 2160),
	"2560x1440": Vector2i(2560, 1440),
	"1920x1080": Vector2i(1920, 1080),
	"1366x768": Vector2i(1366, 768),
	"1280x720": Vector2i(1280, 720),
	"1440x900": Vector2i(1440, 900),
	"1600x900": Vector2i(1600, 900),
	"1024x600": Vector2i(1024, 600),
	"800x600": Vector2i(800, 600)
}

# -------------------------
# Neues Spiel starten
# -------------------------
func start_new_game() -> void:
	pending_spawn = true
	current_scene = "realworld_classroom_one"
	previous_scene = ""
	
	get_tree().change_scene_to_file("res://scenes/realworld_classroom_one.tscn")

	# jetzt Player deferred
	call_deferred("spawn_player")

func start_from_menu() -> void:
	pending_spawn = true
	previous_scene = ""
	
	# Scene wechseln - Player wird erst nach SceneReady erzeugt
	SaveManager.load_last_scene()
	
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
	else:
		player.can_move = true

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
	else:
		player.can_move = true
	call_deferred("_deferred_play_default_animation")


# -------------------------
# Deferred: Default-Animation sicher spielen
# -------------------------
func _deferred_play_default_animation() -> void:
	call_deferred("_play_default_animation")


func _play_default_animation() -> void:

	if not player or not is_instance_valid(player):
		print("[DEBUG] player invalid, abort")
		return

	print("[DEBUG] Player:", player)

	var anim_sprite := _find_animated_sprite(player)
	print("[DEBUG] _find_animated_sprite():", anim_sprite)

	if anim_sprite == null:
		print("[ERROR] Kein AnimatedSprite2D im Player gefunden!")
		return

	if anim_sprite.sprite_frames == null:
		print("[ERROR] sprite_frames ist NULL!")
		return

	print("[DEBUG] sprite_frames animations:", anim_sprite.sprite_frames.get_animation_names())

	# facing_direction sicher abrufen
	var fd := "down"
	if player is PlayerRealworld:
		print("[DEBUG] player.facing_direction =", player.facing_direction)
		fd = player.facing_direction if player.facing_direction != "" else "down"

	var preferred_anim := "idle_%s" % fd
	print("[DEBUG] preferred_anim =", preferred_anim)

	# hat die Animation?
	if anim_sprite.sprite_frames.has_animation(preferred_anim):
		print("[DEBUG] playing preferred animation:", preferred_anim)
		anim_sprite.play(preferred_anim)
		return

	print("[WARN] preferred animation not found!")

	# Fallback
	var anim_list = anim_sprite.sprite_frames.get_animation_names()
	if anim_list.size() > 0:
		print("[DEBUG] fallback animation:", anim_list[0])
		anim_sprite.play(anim_list[0])
	else:
		print("[ERROR] Keine Animationen in sprite_frames!")


# -------------------------
# Hilfsfunktion: rekursives Finden eines AnimatedSprite2D-Knotens
# -------------------------
func _find_animated_sprite(node: Node) -> AnimatedSprite2D:
	for child in node.get_children():
		print("[SCAN] Node:", child.name, "Type:", child.get_class())
		if child is AnimatedSprite2D:
			print("[FOUND] AnimatedSprite2D at:", child.name)
			return child

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

# Eine Funktion, um den Wert sicher zu ändern und das Signal zu feuern
func set_tutorial_enabled(value: bool) -> void:
	tutorial_on = value
	tutorial_toggled.emit(tutorial_on)
