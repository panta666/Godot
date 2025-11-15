# test_music_manager.gd
# Erbt von der GUT-Test-Klasse.
extends "res://addons/gut/test.gd"

# Das Skript, das wir testen wollen.
# PASSE DIESEN PFAD AN, WENN NÖTIG!
var MusicManagerScript = preload("res://scripts/music_manager.gd")

# Eine Instanz des Managers, die für jeden Test neu erstellt wird.
var manager

# --- Setup / Teardown ---

# Diese Funktion wird VOR JEDEM Test ('test_...') ausgeführt.
# Sie stellt sicher, dass jeder Test mit einer sauberen,
# frischen Instanz des Managers beginnt.
func before_each():
	# Erstellt eine neue Instanz des Skripts.
	manager = MusicManagerScript.new()
	
	# Fügt die Instanz zum Test-Szenenbaum hinzu, damit _ready()
	# aufgerufen wird (was den music_player erstellt).
	# 'autofree' entfernt den Node nach dem Test automatisch.
	add_child_autofree(manager)


# --- Testfälle ---

# Testet, ob der Player beim Start korrekt initialisiert wird.
func test_initialization_creates_player_and_sets_bus():
	# 1. PRÜFEN: Wurde der music_player Node erstellt?
	assert_not_null(manager.music_player, "Der music_player Node sollte in _ready() erstellt werden.")
	
	# 2. PRÜFEN: Wurde der korrekte Audio-Bus zugewiesen?
	assert_eq(manager.music_player.bus, "Music", "Der Audio-Bus sollte auf 'Music' gesetzt sein.")


# Testet, ob der Aufruf von playMusic() den korrekten Track startet.
func test_playMusic_starts_correct_track():
	# 1. AKTION: Spiele die Menü-Musik
	manager.playMusic(manager.MusicType.MENU)
	
	# 2. PRÜFEN: Spielt der Player?
	assert_true(manager.music_player.is_playing(), "Der Player sollte jetzt spielen.")
	
	# 3. PRÜFEN: Ist der korrekte Stream (der WAV-Datei) geladen?
	assert_eq(manager.music_player.stream, manager.TRACKS[manager.MusicType.MENU], "Der korrekte Menü-Stream sollte geladen sein.")


# Testet, ob ein erneuter Aufruf von playMusic() mit demselben Track
# die Musik NICHT neustartet (dank der 'isPlaying'-Prüfung).
func test_playMusic_does_not_restart_if_already_playing():
	manager.playMusic(manager.MusicType.MENU)
	
	# Wir holen uns eine Referenz auf den Stream
	var initial_stream = manager.music_player.stream
	
	# 2. AKTION: Versuche, denselben Track erneut zu spielen
	manager.playMusic(manager.MusicType.MENU)
	
	# 3. PRÜFEN:
	assert_true(manager.music_player.is_playing(), "Der Player sollte immer noch spielen.")
	assert_eq(manager.music_player.stream, initial_stream, "Der Stream sollte derselbe sein (nicht neu geladen).")


# Testet, ob der Manager korrekt von einem Track zum anderen wechselt.
func test_playMusic_switches_tracks_correctly():
	# 1. AKTION: Spiele Menü-Musik
	manager.playMusic(manager.MusicType.MENU)
	assert_eq(manager.music_player.stream, manager.TRACKS[manager.MusicType.MENU], "Stream sollte zuerst MENÜ sein.")

	# 2. AKTION: Wechsle zur Hub-Musik
	manager.playMusic(manager.MusicType.HUB)
	
	# 3. PRÜFEN:
	assert_true(manager.music_player.is_playing(), "Der Player sollte nach dem Wechsel noch spielen.")
	assert_eq(manager.music_player.stream, manager.TRACKS[manager.MusicType.HUB], "Stream sollte jetzt HUB sein.")


# Testet, ob die stop_music() Funktion den Player stoppt.
func test_stop_music_stops_playback():
	manager.playMusic(manager.MusicType.HUB)
	assert_true(manager.music_player.is_playing(), "Player sollte anfangs spielen.")
	
	# 2. AKTION: Stoppe die Musik
	manager.stop_music()
	
	# 3. PRÜFEN:
	assert_false(manager.music_player.is_playing(), "Player sollte jetzt gestoppt sein.")


# Testet, ob der Aufruf von playMusic mit NONE die Musik stoppt.
func test_playMusic_NONE_stops_playback():
	manager.playMusic(manager.MusicType.HUB)
	assert_true(manager.music_player.is_playing(), "Player sollte anfangs spielen.")

	# 2. AKTION: Spiele "NONE"
	manager.playMusic(manager.MusicType.NONE)
	
	# 3. PRÜFEN:
	assert_false(manager.music_player.is_playing(), "Player sollte nach dem Abspielen von NONE gestoppt sein.")


# Testet, ob die isPlaying() Funktion den korrekten Status zurückgibt.
func test_isPlaying_returns_correct_state():
	# 1. PRÜFEN (Gestoppt):
	assert_false(manager.isPlaying(manager.MusicType.MENU), "Sollte nicht spielen, wenn gestoppt.")
	
	# 2. AKTION: Spiele MENÜ
	manager.playMusic(manager.MusicType.MENU)
	
	# 3. PRÜFEN (Spielend):
	assert_true(manager.isPlaying(manager.MusicType.MENU), "Sollte melden, dass MENÜ spielt.")
	assert_false(manager.isPlaying(manager.MusicType.HUB), "Sollte nicht melden, dass HUB spielt.")
	assert_false(manager.isPlaying(manager.MusicType.NONE), "Sollte nicht melden, dass NONE spielt.")

	# 4. AKTION: Stoppe Musik
	manager.stop_music()
	
	# 5. PRÜFEN (Wieder gestoppt):
	assert_false(manager.isPlaying(manager.MusicType.MENU), "Sollte nach dem Stoppen nicht mehr spielen.")
