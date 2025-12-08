extends Node2D

@export var timeline_1: String = "level_one_timeline"
@onready var dialog_trigger: Area2D = $DialogTrigger

var cutscene_played := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(Callable(self, "_on_dialogic_signal"))
	
	dialog_trigger.body_entered.connect(_on_dialog_trigger_entered)
	# Speichert die aktuelle Szene für continue
	SaveManager.update_current_scene()
	MusicManager.stop_music()

func _on_dialog_trigger_entered(body: Node) -> void:
	# 1. Ist der Body selbst der Player?
	if body.has_method("player"):
		start_cutscene_with(body)
		return

	# 2. Ist der Parent des Bodys der Player?
	if body.get_parent() and body.get_parent().has_method("player"):
		start_cutscene_with(body.get_parent())
		return

	# 3. Sonst ignorieren
	print("Kein Player:", body.name)

func start_cutscene_with(player: Node):
	if cutscene_played:
		return
	_start_cutscene(player, timeline_1)
	cutscene_played = true


func _start_cutscene(body: Node, timeline_name: String) -> void:
	print("Versuche Cutscene zu starten:", timeline_name, "für", body.name)
	if not body.has_method("player"):
		print("Body ist kein Spieler!")
		return
	if body.has_method("cutscene_start"):
		print("cutscene_start() aufgerufen für", body.name)
		body.cutscene_start()
		body.is_cutscene_active = true
	var timeline = Dialogic.start(timeline_name)
	if not timeline:
		push_error("Dialogic.start() returned null für timeline: %s" % timeline_name)
		body.is_cutscene_active = false
		return
	print("Cutscene erfolgreich gestartet:", timeline_name)
	
func _on_dialogic_signal(event_name: String) -> void:
	if event_name.begins_with("cutscene_end"):
		var player = get_node_or_null("Player_Dreamworld")
		if player and player.has_method("cutscene_end"):
			player.cutscene_end()
			print("cutscene_end() aufgerufen für", player.name)
	elif event_name == "get_doublejump":
		print("Dialogic Event 'get_doublejump' empfangen!")
		var player = get_node_or_null("Player_Dreamworld")
		if player and player.has_method("activate_double_jump"):
			player.activate_double_jump()
			print("Double Jump für Spieler aktiviert!")
