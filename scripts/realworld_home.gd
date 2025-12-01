extends RealworldScenes

@export var dialog_timeline: String = "home_timeline"
var dialog_played := false

func _ready() -> void:
	player_spawn = Vector2(-82, 130)
	scene_name = "realworld_home"
	previous_scene_spawn = Vector2(368, 170) # Wenn aus Hall kommt
	super._ready()
	Dialogic.signal_event.connect(_on_dialogic_signal)


func _on_area_2d_dialog_body_entered(body: Node2D) -> void:
	if dialog_played:
		return
	if not body.has_method("player"):
		return
	print("Realworld Dialog gestartet...")
	_start_realworld_dialog(body, dialog_timeline)
	dialog_played = true
	
func _start_realworld_dialog(player: Node, timeline_name: String) -> void:
	if player.has_method("cutscene_start"):
		player.cutscene_start()

	var timeline = Dialogic.start(timeline_name)
	if not timeline:
		push_error("Dialogic.start() returned null für Timeline: %s" % timeline_name)
		return

	print("Realworld Cutscene gestartet:", timeline_name)


func _on_dialogic_signal(event_name: String) -> void:
	if event_name.begins_with("cutscene_end"):
		var player = GlobalScript.player
		if player and player.has_method("cutscene_end"):
			player.cutscene_end()
			print("Realworld Cutscene beendet, Spieler freigegeben!")
