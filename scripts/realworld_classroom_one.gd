extends RealworldScenes
@onready var classroom_ambiance_player: AudioStreamPlayer = $SFX/ClassroomAmbiancePlayer


func _ready() -> void:
	classroom_ambiance_player.play()
	scene_name = "realworld_classroom_one"
	player_spawn = Vector2(504, 340)        # Standardposition
	previous_scene_spawn = Vector2(568, 362) # Position, wenn aus Hall kommt
	super._ready()  # Basisklasse _ready aufrufen
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(event_name: String) -> void:
	# Cutscene freigeben
	if event_name.begins_with("cutscene_end"):
		var player = GlobalScript.player
		if player and player.has_method("cutscene_end"):
			player.cutscene_end()
			print("Cutscene beendet, Spieler freigegeben!")
