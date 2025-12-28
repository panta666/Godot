extends RealworldScenes
@onready var classroom_ambiance_player: AudioStreamPlayer = $SFX/ClassroomAmbiancePlayer

func _ready() -> void:
	classroom_ambiance_player.play()
	player_spawn = Vector2(1381, 710) # Wenn aus Traumwelt kommt
	scene_name = "realworld_classroom_two"
	previous_scene_spawn = Vector2(1135, 710) # Wenn aus Hall kommt
	super._ready()
	Dialogic.signal_event.connect(_on_dialogic_signal)


func _on_dialogic_signal(event_name: String) -> void:
	var player = GlobalScript.player
	if not player:
		return

	# --- Cutscene Ende ---
	if event_name.begins_with("cutscene_end"):
		if player.has_method("cutscene_end"):
			player.cutscene_end()
			print("Cutscene beendet, Spieler freigegeben!")
