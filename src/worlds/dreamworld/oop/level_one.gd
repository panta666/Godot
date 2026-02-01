extends Node2D

@export var timeline_1: String = "level_one_timeline"
@export var timeline_2: String = "level_one_keys_timeline"
@export var timeline_2_no_key: String = "level_one_no_keys_timeline"
@export var timeline_2_all_keys: String = "level_one_all_keys_timeline"
@onready var dialog_trigger: Area2D = $DialogTrigger
@onready var dialog_trigger2: Area2D = $DialogTrigger2

@onready var drop_manager: Node = $Drop_Manager

var cutscene1_played := false
var cutscene_no_keys_played := false
var cutscene_some_keys_played := false
var cutscene_all_keys_played := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(Callable(self, "_on_dialogic_signal"))

	dialog_trigger.body_entered.connect(_on_dialog_trigger_entered_timeline1)
	dialog_trigger2.body_entered.connect(_on_dialog_trigger_entered_timeline2)
	# Speichert die aktuelle Szene für continue
	SaveManager.update_current_scene()
	MusicManager.playMusic(MusicManager.MusicType.OOP)

func _on_dialog_trigger_entered_timeline1(body: Node) -> void:
	if is_player(body):
		start_cutscene_with(body, timeline_1)

func _on_dialog_trigger_entered_timeline2(body: Node) -> void:
	if not is_player(body):
		return
	
	var keys: int = drop_manager.get_key_status()
	print("Keys aktuell:", keys)

	if keys == 0:
		print("Keine Schlüssel vorhanden")
		start_cutscene_with(body, timeline_2_no_key)
		find_child("hud_key_fragments").get_child(0).visible = true

	elif keys < 4:
		print("Ein oder mehrere Schlüssel vorhanden")
		start_cutscene_with(body, timeline_2)
		find_child("hud_key_fragments").get_child(0).visible = true

	else:
		print("Alle Schlüssel gesammelt")
		start_cutscene_with(body, timeline_2_all_keys)

func start_cutscene_with(player: Node, timeline_name: String):
	match timeline_name:
		timeline_1:
			if cutscene1_played:
				return
			cutscene1_played = true

		timeline_2_no_key:
			if cutscene_no_keys_played:
				return
			cutscene_no_keys_played = true

		timeline_2:
			if cutscene_some_keys_played:
				return
			cutscene_some_keys_played = true

		timeline_2_all_keys:
			if cutscene_all_keys_played:
				return
			cutscene_all_keys_played = true

	_start_cutscene(player, timeline_name)

func is_player(body: Node) -> bool:
	if body.has_method("player"):
		return true
	if body.get_parent() and body.get_parent().has_method("player"):
		return true
	return false

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
			SaveManager.set_player_unlock("double_jump")
			print("Double Jump für Spieler aktiviert!")
