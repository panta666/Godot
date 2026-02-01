extends RealworldScenes
@onready var classroom_ambiance_player: AudioStreamPlayer = $SFX/ClassroomAmbiancePlayer
@onready var quest_trigger2: QuestTrigger = $QuestTrigger2
@onready var quest_trigger3: QuestTrigger = $QuestTrigger3


func _ready() -> void:
	classroom_ambiance_player.play()
	scene_name = "realworld_classroom_one"
	player_spawn = Vector2(190, 345) # Position wenn aus Traumwelt kommt
	previous_scene_spawn = Vector2(568, 362) # Position, wenn aus Hall kommt
	super._ready()  # Basisklasse _ready aufrufen
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	# Prüfen, ob Level OOP Level 2 freigeschaltet ist
	if GlobalScript.is_level_unlocked(GlobalScript.classrooms.oop, 2):
		quest_trigger2.set_enabled(true)
		print("QuestTrigger2 aktiviert, OOP Level 2 freigeschaltet!")
		
	# Prüfen, ob Math Door unlocked ist
	if GlobalScript.is_level_unlocked(GlobalScript.classrooms.mathe, 1):
		quest_trigger3.set_enabled(true)
		print("QuestTrigger3 aktiviert, Math Level freigeschaltet!")

func _on_dialogic_signal(event_name: String) -> void:
	# Cutscene freigeben
	if event_name.begins_with("cutscene_end"):
		var player = GlobalScript.player
		if player and player.has_method("cutscene_end"):
			player.cutscene_end()
			print("Cutscene beendet, Spieler freigegeben!")
