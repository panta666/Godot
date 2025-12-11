# SaveManager.gd
extends Node

# Der Pfad, unter dem die Speicherdatei abgelegt wird.
const SAVE_PATH = "user://game_save.dat"

# Das Haupt-Dictionary, das alle Speicherdaten enthält.
# Hier werden die Standardwerte für ein neues Spiel definiert.
var save_data = {
	"game_progress": {
		"current_scene_path": "MainMenu" # Standard-Startszene (passe dies an)
	},
	"audio_settings": {
		"Master": 0.0,   # 0.0 dB ist volle Lautstärke
		"Music": -13.0,
		"SFX": 0.0,
		"is_muted": false
	},
	"player_stats": {
		"coins": 0,
		"double_jump": false,
		"dash": false,
		"range_attack": false,
		"crouching": false,
		"range_attack_increase": false
	}
}


# Wird aufgerufen, sobald das Spiel startet (dank Autoload).
func _ready():
	# Lädt das Spiel und wendet die Soundeinstellungen sofort an.
	load_game()


## ----------------------------------------------------------------
## KERNFUNKTIONEN: Speichern und Laden (Intern)
## ----------------------------------------------------------------

# Speichert das aktuelle 'save_data'-Dictionary in die Datei.
func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Fehler beim Öffnen der Speicherdatei zum Schreiben.")
		return

	# Konvertiert das Dictionary in eine JSON-Zeichenkette.
	var json_string = JSON.stringify(save_data)
	file.store_string(json_string)
	file.close()
	print("SaveManager: Spiel gespeichert.")


# Lädt die Daten aus der Datei und wendet die Audio-Einstellungen an.
func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("SaveManager: Keine Speicherdatei gefunden. Standardwerte werden verwendet.")
		# Wendet die Standard-Audioeinstellungen an, wenn kein Spielstand vorhanden ist.
		apply_audio_settings()
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: Fehler beim Öffnen der Speicherdatei zum Lesen.")
		return

	var content = file.get_as_text()
	file.close()

	var parse_result = JSON.parse_string(content)
	if parse_result is Dictionary:
		# Führt die geladenen Daten mit den Standarddaten zusammen.
		# Dies stellt sicher, dass neue Schlüssel (z.B. "coins") nicht fehlschlagen.
		save_data.merge(parse_result, true)
		print("SaveManager: Spielstand geladen.")
	else:
		push_error("SaveManager: Speicherdatei ist korrupt.")

	# Wendet die geladenen Audioeinstellungen sofort an.
	apply_audio_settings()


# Wendet die im 'save_data'-Dictionary gespeicherten Audioeinstellungen an.
func apply_audio_settings():
	var settings = save_data["audio_settings"]
	
	# WICHTIG: Godot verwendet Dezibel (dB) für die Lautstärke. 0.0 ist max, -80.0 ist stumm.
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), settings["Master"])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), settings["Music"])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), settings["SFX"])
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), settings["is_muted"])
	print("SaveManager: Audioeinstellungen angewendet.")


## ----------------------------------------------------------------
## ÖFFENTLICHE FUNKTIONEN: Von anderen Skripten aufrufen
## ----------------------------------------------------------------

func update_bus_volume(audio_bus_id: int, volume: float):
	if (audio_bus_id < Global.AUDIO_BUSES.size()):
		save_data["audio_settings"][Global.AUDIO_BUSES[audio_bus_id]] = volume
		save_game()
	else:
		push_error("Bus unknown!")


func update_is_muted(is_muted: bool):
	save_data["audio_settings"]["is_muted"] = is_muted
	save_game()


# Wird von deiner Spiellogik aufgerufen (z.B. beim Erreichen eines Checkpoints).
func update_current_scene():
	print("save szene: ", GlobalScript.current_scene)
	save_data["game_progress"]["current_scene_path"] = GlobalScript.current_scene
	save_game()

# (Vorbereitet für die Zukunft)
# func update_coins(amount: int):
#    save_data["player_stats"]["coins"] = amount
#    save_game()


## ----------------------------------------------------------------
## GETTER-FUNKTIONEN: Zum Abrufen von Daten
## ----------------------------------------------------------------

# Wird vom Hauptmenü aufgerufen, um den "Continue"-Button zu starten.
func load_last_scene():
	GlobalScript.previous_scene = ""
	var scene_path = save_data["game_progress"]["current_scene_path"]
	print("lade Szene: " + scene_path)
	
	# Verhindert den Start im Menü, wenn "Weiter" geklickt wird
	if scene_path == "MainMenu":
		scene_path = "realworld_classroom_one" # Passe dies an deine erste Szene nach dem Menü an
	GlobalScript.current_scene = scene_path
	#if get_tree().change_scene_to_file("res://scenes/%s.tscn" % scene_path) != OK:
	#	push_error("SaveManager: Gespeicherte Szene ungültig. Lade Fallback-Szene.")
	#GlobalScript.current_scene = "realworld_classroom_one"
	GlobalScript.change_scene(scene_path)

# Wird vom Einstellungsmenü aufgerufen, um die Slider/Checkboxen zu füllen.
func get_audio_settings() -> Dictionary:
	return save_data["audio_settings"]

# (Vorbereitet für die Zukunft)
# func get_coins() -> int:
#    return save_data["player_stats"]["coins"]
