extends RealworldScenes

func _ready() -> void:
	player_spawn = Vector2(-82, 130)
	scene_name = "realworld_home"
	previous_scene_spawn = Vector2(368, 170) # Wenn aus Hall kommt
	super._ready()
	Dialogic.signal_event.connect(_on_dialogic_signal)


func _on_dialogic_signal(event_name: String) -> void:
	if event_name.begins_with("cutscene_end"):
		var player = GlobalScript.player
		if player and player.has_method("cutscene_end"):
			player.cutscene_end()
			print("Realworld Cutscene beendet, Spieler freigegeben!")
