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
	
	# QuestTrigger2 standardmäßig deaktivieren
	var trigger := $QuestTrigger2
	trigger.monitoring = false
	trigger.monitorable = false
	trigger.get_node("CollisionShape2D").disabled = true

	# Prüfen, ob Level OOP Level 2 freigeschaltet ist
	if GlobalScript.is_level_unlocked(GlobalScript.classrooms.oop, 2):
		trigger.monitoring = true
		trigger.monitorable = true
		trigger.get_node("CollisionShape2D").disabled = false
		print("QuestTrigger2 aktiviert, OOP Level 2 freigeschaltet!")
		
	# QuestTrigger3 standardmäßig deaktivieren
	var trigger2 := $QuestTrigger3
	trigger2.monitoring = false
	trigger2.monitorable = false
	trigger2.get_node("CollisionShape2D").disabled = true

	# Prüfen, ob Math Door unlocked ist
	if GlobalScript.is_level_unlocked(GlobalScript.classrooms.mathe, 1):
		trigger2.monitoring = true
		trigger2.monitorable = true
		trigger2.get_node("CollisionShape2D").disabled = false
		print("QuestTrigger3 aktiviert, Math Level freigeschaltet!")

func _on_dialogic_signal(event_name: String) -> void:
	# Cutscene freigeben
	if event_name.begins_with("cutscene_end"):
		var player = GlobalScript.player
		if player and player.has_method("cutscene_end"):
			player.cutscene_end()
			print("Cutscene beendet, Spieler freigegeben!")
