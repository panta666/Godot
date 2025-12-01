extends Node2D

@export var timeline_name: String = "tutorial_start_cutscene_timeline"

var cutscene_played: bool = false # Flag, um zu prüfen ob die cutscene bereits lief

func _ready():
	# Dialogic-Signal global verbinden
	Dialogic.signal_event.connect(Callable(self, "_on_dialogic_signal"))

func _on_area_2d_body_entered(body: Node) -> void:
	if cutscene_played:
		return
	print("Area betreten von:", body.name)

	if not body.has_method("player"):
		print("kein Spieler")
		return

	print("Spieler erkannt, starte Cutscene...")

	# Spieler bewegungsunfähig machen
	if body.has_method("cutscene_start"):
		body.cutscene_start()
		print("cutscene_start() aufgerufen")

	# Cutscene-Flag setzen
	body.is_cutscene_active = true
	print("is_cutscene_active gesetzt auf true")

	# Dialog starten
	var timeline = Dialogic.start(timeline_name)
	if not timeline:
		push_error("Dialogic.start() returned null for timeline: %s" % timeline_name)
		body.is_cutscene_active = false
		return
	print("Dialogic-Timeline gestartet:", timeline.name)

# Cutscene als gespielt markieren
	cutscene_played = true

# Reagiere auf Dialogic-Events aus der Timeline
func _on_dialogic_signal(event_name: String) -> void:
	if event_name == "cutscene_end":
		print("Cutscene beendet via Dialogic-Signal!")
		# Spieler wieder freigeben
		var player = get_node_or_null("Player_Dreamworld")
		if player and player.has_method("cutscene_end"):
			player.cutscene_end()
			print("cutscene_end() aufgerufen")
		
