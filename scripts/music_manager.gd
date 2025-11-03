# MusicManager.gd (Autoload)
extends Node

# 1. Pfade zu den Musikdateien (wie gewünscht angepasst)
const MENU_MUSIC = preload("res://assets/music/MainMenuTheme.wav")
const HUB_MUSIC = preload("res://assets/music/Hubworld theme.mp3")

# (Optional: Fügen Sie hier später Ihre Dreamworld-Musik hinzu)
# const DREAM_MUSIC = preload("res://assets/music/DreamworldTheme.mp3")

# Der Player, der die Musik verwaltet
var music_player: AudioStreamPlayer

func _ready():
	# Erstellt den AudioStreamPlayer und fügt ihn dem MusicManager hinzu
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

## --- STEUERUNGSFUNKTIONEN ---

# Diese Funktion rufen Sie auf, wenn die Hubworld betreten wird
func play_hub_music():
	# Prüfen, ob die Hub-Musik bereits läuft
	if music_player.playing and music_player.stream == HUB_MUSIC:
		return # Nichts tun, sie läuft schon
		
	music_player.stream = HUB_MUSIC
	music_player.play()

# Diese Funktion rufen Sie auf, wenn das Hauptmenü betreten wird
func play_menu_music():
	# Prüfen, ob die Menü-Musik bereits läuft
	if music_player.playing and music_player.stream == MENU_MUSIC:
		return # Nichts tun, sie läuft schon
	
	music_player.stream = MENU_MUSIC
	music_player.play()

# Diese Funktion rufen Sie auf, wenn die Musik komplett stoppen soll
# (z.B. beim Betreten einer Dreamworld oder in Ladebildschirmen)
func stop_music():
	music_player.stop()
