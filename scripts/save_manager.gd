# SaveManager.gd
extends Node
signal shop_unlocked_signal

# Der Pfad, unter dem die Speicherdatei abgelegt wird.
const SAVE_PATH = "user://game_save.dat"

# Das Haupt-Dictionary, das alle Speicherdaten enthält.
# Hier werden die Standardwerte für ein neues Spiel definiert.
var save_data = {
	"game_progress": {
		"current_scene_path": "MainMenu", # Standard-Startszene (passe dies an)
		"coins" : {
			"realworld": 0,
			"oop_level_one": [], #Szenenname des coins speichern
			"math_level_one": []
		},
		"quests": [],
		"unlocked_doors": {},
		"shop_unlocked": false
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

const default_values = {
	"game_progress": {
		"current_scene_path": "MainMenu", # Standard-Startszene
		"coins" : {
			"realworld": 0,
			"oop_level_one": [], #Szenenname des coins speichern
			"math_level_one": []
		},
		"quests": [],
		"unlocked_doors": {},
		"shop_unlocked": false
	},
	"audio_settings": {
		"Master": 0.0,   # 0.0 dB ist volle Lautstärke
		"Master_is_muted": false,
		"Music": -13.0,
		"Music_is_muted": false,
		"SFX": 0.0,
		"SFX_is_muted": false
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
	validate_data(save_data, default_values)

func reset_game():
	var audio_settings = get_audio_settings()
	save_data = default_values.duplicate(true)
	save_data["audio_settings"] = audio_settings.duplicate()
	save_game()

# Gibt wieder ob ein Quest bereits getriggerd wurde.
func get_quest_already_triggered(id: String) -> bool:
	return save_data["game_progress"]["quests"].has(id)

func set_quest_triggered(id: String):
	save_data["game_progress"]["quests"].append(id)
	save_game()

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

func save_coin(coins: Array, level: String):
	for coin in coins:
		print("save coin", coin)
		save_data["game_progress"]["coins"][level].append(coin)

func save_realworld_coin(value: int):
	save_data["game_progress"]["coins"]["realworld"] = value

func get_realworld_coins():
	return save_data["game_progress"]["coins"]["realworld"]

func get_dreamworld_coins(level:String = ""):
	if level == "":
		return save_data["game_progress"]["coins"]
	elif save_data["game_progress"]["coins"].has(level):
		return save_data["game_progress"]["coins"][level]
	else:
		return 0

func get_ammount_dreamworld_coins(level:String):
	if save_data["game_progress"]["coins"].has(level):
		return len(save_data["game_progress"]["coins"][level])
	else:
		return 0

func coin_is_collected(level: String, coin_name: String) -> bool:
	var is_collected = false
	if save_data["game_progress"]["coins"].has(level) == true:
		if coin_name in save_data["game_progress"]["coins"][level]:
			is_collected = true
	return is_collected

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

	# Wenn neue Einstellungen zum speichern dazukommen überschreibe mit defautl.
	validate_data(save_data, default_values)
	# Wendet die geladenen Audioeinstellungen sofort an.
	apply_audio_settings()
	
	check_for_player_settings()

func check_for_player_settings():
	if save_data.has("player_stats") == false:
		save_data["player_stats"]["double_jump"] = false
		save_data["player_stats"]["coins"] = 0
		save_data["player_stats"]["double_jump"] = false
		save_data["player_stats"]["dash"] = false
		save_data["player_stats"]["range_attack"] = false
		save_data["player_stats"]["crouching"] = false
		save_data["player_stats"]["range_attack_increase"] = false

# Wendet die im 'save_data'-Dictionary gespeicherten Audioeinstellungen an.
func apply_audio_settings():
	var settings = save_data["audio_settings"]
	
	# WICHTIG: Godot verwendet Dezibel (dB) für die Lautstärke. 0.0 ist max, -80.0 ist stumm.
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), settings["Master"])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), settings["Music"])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), settings["SFX"])
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), settings["Master_is_muted"])
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), settings["Music_is_muted"])
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), settings["SFX_is_muted"])
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


func update_is_muted(audio_bus_id: int,is_muted: bool):
	var bus_is_muted = Global.AUDIO_BUSES[audio_bus_id] + "_is_muted"
	save_data["audio_settings"][bus_is_muted] = is_muted
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

# Door Unlock um z.B: die MATH Door aufzuschließen/abzuschließen zu Beginn
func unlock_door(door_id: String):
	if not save_data["game_progress"]["unlocked_doors"].has(door_id):
		save_data["game_progress"]["unlocked_doors"][door_id] = true
		save_game()

func is_door_unlocked(door_id: String) -> bool:
	return save_data["game_progress"]["unlocked_doors"].get(door_id, false)
	
# Shop Unlock
func unlock_shop():
	if not save_data["game_progress"]["shop_unlocked"]:
		save_data["game_progress"]["shop_unlocked"] = true
		save_game()
		emit_signal("shop_unlocked_signal")  # Signal aussenden!

func is_shop_unlocked() -> bool:
	return save_data["game_progress"]["shop_unlocked"]

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

# ----------------------------------------------------------------
# VALIDIERUNGS-LOGIK (Rekursiv)
# ----------------------------------------------------------------

# Diese Funktion prüft 'target' gegen 'defaults'.
# Wenn Keys in 'target' fehlen, werden sie aus 'defaults' kopiert.
# Wenn ein Wert ein Dictionary ist, wird rekursiv geprüft.
func validate_data(target: Dictionary, defaults: Dictionary) -> void:
	for key in defaults:
		# 1. Existiert der Key im geladenen Dictionary?
		if not target.has(key):
			print("SaveManager: Fehlender Key gefunden: '", key, "'. Füge Default hinzu.")
			# Key fehlt -> Wert aus Default kopieren
			# WICHTIG: Bei Arrays/Dicts 'duplicate' nutzen, um Referenzen zu vermeiden
			var default_val = defaults[key]
			if default_val is Dictionary or default_val is Array:
				target[key] = default_val.duplicate(true)
			else:
				target[key] = default_val

		# Da wir ihn gerade frisch hinzugefügt haben, müssen wir nicht tiefer prüfen
			continue

		# 2. Key existiert. Ist es ein Dictionary, das wir tiefer prüfen müssen?
		var target_val = target[key]
		var default_val = defaults[key]

		# Wenn BEIDES Dictionaries sind -> Rekursion!
		if target_val is Dictionary and default_val is Dictionary:
			validate_data(target_val, default_val)

		# Optional: Typ-Sicherheit prüfen (Wenn im Save 'coins' plötzlich ein String ist)
		elif typeof(target_val) != typeof(default_val) and default_val != null:
			print("SaveManager: Falscher Datentyp für '", key, "'. Setze auf Default zurück.")
			target[key] = default_val
