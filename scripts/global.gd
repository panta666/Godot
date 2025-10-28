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

# Konstante für den Dateinamen des Speicherstands
const SAVE_PATH = "user://savegame.dat"

# --- Zu speichernde Daten ---
# 1. Level-Fortschritt
var level_progress: int = 0
# 2. Aktueller Szenenpfad (Für das Laden der korrekten Szene)
var current_scene_path: String = "res://scenes/main_menu.tscn" # Oder Startszene
# 3. Münzen (erstmal auskommentiert, aber vorbereitet)
# var coins: int = 0

var current_scene = 'realworld_classroom_one'
var transition_scene  = false

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
	# 🔹 Dialogic-Instanz entfernen, wenn vorhanden
	var dialogic_node = get_tree().root.get_node_or_null("DialogicLayout_VisualNovelStyle")
	if dialogic_node:
		print("Entferne alte Dialogic-Instanz vor Szenenwechsel …")
		dialogic_node.queue_free()

	# 🔹 Alte Szene entfernen
	var old_scene = get_tree().current_scene
	if old_scene:
		old_scene.queue_free()

	# 🔹 Neue Szene laden
	var scene_path := "res://scenes/%s.tscn" % new_scene
	var new_scene_instance = load(scene_path).instantiate()
	get_tree().root.add_child(new_scene_instance)
	get_tree().current_scene = new_scene_instance

	current_scene = new_scene

	# 🔹 Player verschieben oder neu hinzufügen
	move_player_to_current_scene()

	# 🔹 Sichtbarkeit sicherstellen
	if player:
		player.visible = true
		player.can_move = true
		print("Player wurde nach Szenenwechsel in %s gesetzt" % new_scene)

# =================================================================
#                         SAVE-FUNKTION
# =================================================================

func save_game():
	# 1. FileAccess-Objekt erstellen
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		# Fehlerbehandlung, falls die Datei nicht geöffnet werden kann
		print("FEHLER: Konnte Speicherdatei nicht öffnen zum Schreiben.")
		return

	# 2. Daten sammeln (Dictionary-Format ist ideal zum Speichern)
	var save_data = {
		"level_progress": level_progress,
		"current_scene_path": current_scene_path,
		# "coins": coins, # Auskommentiert
	}

	# 3. Daten schreiben (JSON-Format ist leicht lesbar und stabil)
	file.store_line(JSON.stringify(save_data))

	# 4. Datei schließen
	file.close()
	print("Spiel gespeichert: ", current_scene_path)


# =================================================================
#                         LOAD-FUNKTION
# =================================================================

func load_game() -> bool:
	# 1. Prüfen, ob eine Speicherdatei existiert
	if not FileAccess.file_exists(SAVE_PATH):
		print("Kein Speicherstand gefunden.")
		return false # Laden fehlgeschlagen

	# 2. Datei öffnen und lesen
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		print("FEHLER: Konnte Speicherdatei nicht öffnen zum Lesen.")
		return false

	var content = file.get_as_text()
	file.close()

	# 3. Inhalt parsen (von JSON zurück zu Dictionary)
	var json_result = JSON.parse_string(content)
	if json_result is not Dictionary:
		print("FEHLER: Speicherdatei korrupt.")
		return false

	var loaded_data = json_result

	# 4. Globale Variablen aktualisieren
	level_progress = loaded_data.get("level_progress", 0) # Fallback-Wert 0
	current_scene_path = loaded_data.get("current_scene_path", current_scene_path)
	# coins = loaded_data.get("coins", 0) # Auskommentiert

	print("Spiel geladen. Fortschritt: ", level_progress)
	return true # Laden erfolgreich

# =================================================================
#                         SZENE WECHSELN UND LADEN
# =================================================================

func load_scene():
	# Lädt die Szene, deren Pfad in der globalen Variablen gespeichert ist
	get_tree().change_scene_to_file(current_scene_path)
