extends Node2D

class_name EnemySoundPlayer # Damit wir es leicht finden

# Referenzen
@onready var audio_move: AudioStreamPlayer2D = $AudioMove
@onready var audio_action: AudioStreamPlayer2D = $AudioAction

# Exportierte Variablen für MODULARITÄT
# Ziehe hier im Editor die wav/ogg Dateien rein!
@export_group("Sounds")
@export var sound_attack: AudioStream
@export var sound_get_hit: AudioStream
@export var sound_die: AudioStream
@export var sound_pre_attack: AudioStream
@export var sound_walk: Array[AudioStream] = [] # Array für Variationen

func play_sound(soundtype: Enemysound.soundtype):
	match soundtype:
		# --- BEWEGUNG ---
		Enemysound.soundtype.WALK:
			if sound_walk.is_empty(): return
			
			if not audio_move.playing:
				# Zufälligen Sound aus dem Array
				audio_move.stream = sound_walk.pick_random()
				audio_move.pitch_scale = randf_range(0.9, 1.1)
				audio_move.play()

		# --- ACTION ---
		Enemysound.soundtype.ATTACK:
			_play_action(sound_attack)
		Enemysound.soundtype.GET_HIT:
			_play_action(sound_get_hit)
		Enemysound.soundtype.DIE:
			_play_action(sound_die)
		Enemysound.soundtype.PRE_ATTAK:
			_play_action(sound_pre_attack)

# Hilfsfunktion, um Code-Duplizierung zu vermeiden
func _play_action(stream: AudioStream):
	if stream: # Nur abspielen, wenn ein Sound zugewiesen ist
		audio_action.stream = stream
		audio_action.pitch_scale = randf_range(0.95, 1.05)
		audio_action.play()

func stop_move_sound():
	if audio_move.playing:
		audio_move.stop()

func stop_all():
	audio_move.stop()
	audio_action.stop()
