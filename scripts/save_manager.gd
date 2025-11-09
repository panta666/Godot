# SaveManager.gd
extends Node

# Der Pfad, unter dem die Speicherdatei abgelegt wird.
const SAVE_PATH = "user://game_save.dat"

# Das Haupt-Dictionary, das alle Speicherdaten enthält.
# Hier werden die Standardwerte für ein neues Spiel definiert.
var save_data = {
	"game_progress": {
		"current_scene_path": "res://scenes/MainMenu.tscn" # Standard-Startszene (passe dies an)
	},
	"audio_settings": {
		"master_bus_volume_db": 0.0,   # 0.0 dB ist volle Lautstärke
		"music_bus_volume_db": -13.0,
		"sfx_bus_volume_db": 0.0,
		"is_muted": false
	},
	"player_stats": {
		"coins": 0 # Vorbereitet für die Zukunft
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
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), settings["master_bus_volume_db"])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), settings["music_bus_volume_db"])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), settings["sfx_bus_volume_db"])
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), settings["is_muted"])
	print("SaveManager: Audioeinstellungen angewendet.")


## ----------------------------------------------------------------
## ÖFFENTLICHE FUNKTIONEN: Von anderen Skripten aufrufen
## ----------------------------------------------------------------

# Wird vom Einstellungsmenü (Options.gd) aufgerufen.
func update_audio_settings(main_vol_db, music_vol_db, sfx_vol_db, is_muted):
	save_data["audio_settings"]["master_bus_volume_db"] = main_vol_db
	save_data["audio_settings"]["music_bus_volume_db"] = music_vol_db
	save_data["audio_settings"]["sfx_bus_volume_db"] = sfx_vol_db
	save_data["audio_settings"]["is_muted"] = is_muted
	
	# Speichert bei jeder Änderung sofort (wie gewünscht).
	save_game()
	# Wendet die Einstellungen auch sofort an (falls 'is_muted' geändert wurde).
	apply_audio_settings()

# Wird von deiner Spiellogik aufgerufen (z.B. beim Erreichen eines Checkpoints).
func update_current_scene(scene_path: String):
	save_data["game_progress"]["current_scene_path"] = scene_path
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
	var scene_path = save_data["game_progress"]["current_scene_path"]
	
	# Verhindert den Start im Menü, wenn "Weiter" geklickt wird
	if scene_path == "res://scenes/MainMenu.tscn":
		scene_path = "res://scenes/realworld_classroom_one.tscn" # Passe dies an deine erste Szene nach dem Menü an
		
	if get_tree().change_scene_to_file(scene_path) != OK:
		push_error("SaveManager: Gespeicherte Szene ungültig. Lade Fallback-Szene.")
		# Passe dies an deine Standard-Startszene an
		get_tree().change_scene_to_file("res://scenes/realworld_classroom_one.tscn")

# Wird vom Einstellungsmenü aufgerufen, um die Slider/Checkboxen zu füllen.
func get_audio_settings() -> Dictionary:
	return save_data["audio_settings"]

# (Vorbereitet für die Zukunft)
# func get_coins() -> int:
#    return save_data["player_stats"]["coins"]
