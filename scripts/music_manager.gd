# MusicManager.gd (Autoload)
# Globaler Singleton-Manager zur Steuerung der Hintergrundmusik (BGM).
extends Node

# Definiert alle verfügbaren Musik-Tracks für typsicheren Zugriff.
enum MusicType {
	NONE,    # Repräsentiert keine Musik (Stille)
	MENU,    # Hauptmenü-Theme
	HUB      # Hubworld-Theme
	# TODO: Zukünftige Tracks hier hinzufügen (z.B. DREAMWORLD)
}

# Bildet die MusicType-Enums auf die vorgeladenen AudioStream-Ressourcen ab.
const TRACKS = {
	MusicType.MENU: preload("res://assets/music/MainMenuTheme.wav"),
	MusicType.HUB: preload("res://assets/music/Hubworld theme.mp3")
}

var music_player: AudioStreamPlayer

# Erstellt den AudioStreamPlayer-Node bei Initialisierung.
func _ready():
	music_player = AudioStreamPlayer.new()
	
	# Player für Hintergrundmusik dem Music bus hinzufügen.
	music_player.bus = "Music"
	
	add_child(music_player)


# Spielt einen bestimmten Musik-Track basierend auf dem übergebenen MusicType.
# Stoppt den aktuellen Track und startet den neuen.
# Verhindert das Neustarten, wenn der angeforderte Track bereits läuft.
func playMusic(music_type: MusicType):
	
	# Nichts tun, wenn der angeforderte Track bereits spielt.
	if isPlaying(music_type):
		return

	# Prüfen, ob der angeforderte music_type gültig ist.
	if not TRACKS.has(music_type):
		# Stoppt die Wiedergabe, wenn der Typ NONE oder ungültig ist.
		stop_music()
		push_error("MusicManager: Ungültiger MusicType oder 'NONE' angefordert. Musik wird gestoppt.")
		return

	# Lädt den neuen Track und startet die Wiedergabe.
	# Das Setzen von .stream stoppt automatisch den vorherigen Track.
	music_player.stream = TRACKS[music_type]
	music_player.play()


# Stoppt die Musikwiedergabe sofort.
func stop_music():
	music_player.stop()


# Prüft, ob ein spezifischer Musik-Track (MusicType) gerade aktiv ist.
func isPlaying(music_type: MusicType) -> bool:
	# Zurückgeben 'false', wenn der Player nicht spielt.
	if not music_player.playing:
		return false
		
	# Prüfen, ob der Typ gültig ist und dem aktuell geladenen Stream entspricht.
	if TRACKS.has(music_type) and music_player.stream == TRACKS[music_type]:
		return true
			
	return false
