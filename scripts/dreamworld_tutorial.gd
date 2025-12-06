extends Node2D

@export var timeline_1: String = "tutorial_start_cutscene_timeline"
@export var timeline_2: String = "tutorial_second_cutscene_timeline"
@export var timeline_3: String = "tutorial_third_cutscene_timeline"
@export var timeline_4: String = "tutorial_fourth_cutscene_timeline"
@export var timeline_5: String = "tutorial_fifth_cutscene_timeline"
@export var timeline_6: String = "tutorial_sixth_cutscene_timeline"
@export var timeline_7: String = "tutorial_seventh_cutscene_timeline"
@export var timeline_8: String = "tutorial_skip_timeline"

@onready var area_2d_cutscene_1: Area2D = $Area2D_Cutscene1
@onready var area_2d_cutscene_2: Area2D = $Area2D_Cutscene2
@onready var area_2d_cutscene_3: Area2D = $Area2D_Cutscene3
@onready var area_2d_cutscene_4: Area2D = $Area2D_Cutscene4
@onready var area_2d_cutscene_5: Area2D = $Area2D_Cutscene5
@onready var area_2d_cutscene_6: Area2D = $Area2D_Cutscene6
@onready var area_2d_cutscene_7: Area2D = $Area2D_Cutscene7
@onready var area_2d_cutscene_8: Area2D = $Area2D_Cutscene8
@onready var platforms_container: Node2D = $PlatformsContainer

var cutscene_1_played := false
var cutscene_2_played := false
var cutscene_3_played := false
var cutscene_4_played := false
var cutscene_5_played := false
var cutscene_6_played := false
var cutscene_7_played := false
var cutscene_8_played := false
var platforms: Array = []

func _ready():
	# Dialogic-Signal global verbinden
	Dialogic.signal_event.connect(Callable(self, "_on_dialogic_signal"))

	# Areas verbinden
	area_2d_cutscene_1.body_entered.connect(_on_cutscene_1_entered)
	area_2d_cutscene_2.body_entered.connect(_on_cutscene_2_entered)
	area_2d_cutscene_3.body_entered.connect(_on_cutscene_3_entered)
	area_2d_cutscene_4.body_entered.connect(_on_cutscene_4_entered)
	area_2d_cutscene_5.body_entered.connect(_on_cutscene_5_entered)
	area_2d_cutscene_6.body_entered.connect(_on_cutscene_6_entered)
	area_2d_cutscene_7.body_entered.connect(_on_cutscene_7_entered)
	area_2d_cutscene_8.body_entered.connect(_on_cutscene_8_entered)

	# Alle Plattformen initial deaktivieren
	for platform in platforms_container.get_children():
		if platform is AnimatableBody2D:
			platform.visible = false
			platform.collision_layer = 0  # keine Kollision
			platform.collision_mask = 0
			platforms.append(platform)
	print("Plattformen initial deaktiviert:", platforms.size())

func _on_cutscene_1_entered(body: Node) -> void:
	if cutscene_1_played:
		return
	_ddddddddart_cutscene(body, timeline_1)
	cutscene_1_played = true

func _on_cutscene_2_entered(body: Node) -> void:
	print("Cutscene 2 Area betreten von:", body.name)
	if cutscene_2_played:
		print("Cutscene 2 bereits gespielt, nichts passiert")
		return
	if not body.has_method("player"):
		print("Body hat keine player-Methode:", body)
		return
	print("Starte Cutscene 2...")
	_start_cutscene(body, timeline_2)
	cutscene_2_played = true
	
func _on_cutscene_3_entered(body: Node) -> void:
	print("Cutscene 3 Area betreten von:", body.name)
	if cutscene_3_played:
		print("Cutscene 3 bereits gespielt, nichts passiert")
		return
	if not body.has_method("player"):
		print("Body hat keine player-Methode:", body)
		return
	print("Starte Cutscene 3...")
	_start_cutscene(body, timeline_3)
	cutscene_3_played = true

func _on_cutscene_4_entered(body: Node) -> void:
	print("Cutscene 4 Area betreten von:", body.name)
	if cutscene_4_played:
		print("Cutscene 4 bereits gespielt, nichts passiert")
		return
	if not body.has_method("player"):
		print("Body hat keine player-Methode:", body)
		return
	print("Starte Cutscene 4...")
	_start_cutscene(body, timeline_4)
	cutscene_4_played = true
	
func _on_cutscene_5_entered(body: Node) -> void:
	print("Cutscene 5 Area betreten von:", body.name)
	if cutscene_5_played:
		print("Cutscene 5 bereits gespielt, nichts passiert")
		return
	if not body.has_method("player"):
		print("Body hat keine player-Methode:", body)
		return
	print("Starte Cutscene 5...")
	_start_cutscene(body, timeline_5)
	cutscene_5_played = true
	
func _on_cutscene_6_entered(body: Node) -> void:
	print("Cutscene 6 Area betreten von:", body.name)
	if cutscene_6_played:
		print("Cutscene 6 bereits gespielt, nichts passiert")
		return
	if not body.has_method("player"):
		print("Body hat keine player-Methode:", body)
		return
	print("Starte Cutscene 6...")
	_start_cutscene(body, timeline_6)
	cutscene_6_played = true
	
func _on_cutscene_7_entered(body: Node) -> void:
	print("Cutscene 7 Area betreten von:", body.name)
	if cutscene_7_played:
		print("Cutscene 7 bereits gespielt, nichts passiert")
		return
	if not body.has_method("player"):
		print("Body hat keine player-Methode:", body)
		return
	print("Starte Cutscene 7...")
	_start_cutscene(body, timeline_7)
	cutscene_7_played = true
	
func _on_cutscene_8_entered(body: Node) -> void:
	print("Cutscene 8 Area betreten von:", body.name)
	if cutscene_8_played:
		print("Cutscene 8 bereits gespielt, nichts passiert")
		return
	if not body.has_method("player"):
		print("Body hat keine player-Methode:", body)
		return
	print("Skip Tutorial...")
	_start_cutscene(body, timeline_8)
	cutscene_8_played = true

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
	elif event_name == "get_platform":
		print("Dialogic Event 'get_platform' empfangen!")
		for platform in platforms:
			platform.visible = true
			# Hier Collisionschicht wieder aktivieren
			platform.collision_layer = 1
			platform.collision_mask = 1
		print("Plattformen aktiviert:", platforms.size())
	elif event_name == "get_doublejump":
		print("Dialogic Event 'get_doublejump' empfangen!")
		var player = get_node_or_null("Player_Dreamworld")
		if player and player.has_method("activate_double_jump"):
			player.activate_double_jump()
			print("Double Jump für Spieler aktiviert!")
	elif event_name == "get_dash":
		print("Dialogic Event 'get_dash' empfangen!")
		var player = get_node_or_null("Player_Dreamworld")
		if player and player.has_method("activate_dash"):
			player.activate_dash()
			print("Dash für Spieler aktiviert!")
	elif event_name == "get_range_attack":
		print("Dialogic Event 'get_range_attack' empfangen!")
		var player = get_node_or_null("Player_Dreamworld")
		if player and player.has_method("activate_range_attack"):
			player.activate_range_attack()
			print("Range Attack für Spieler aktiviert!")
	elif event_name == "get_crouch":
		print("Dialogic Event 'get_crouch' empfangen!")
		var player = get_node_or_null("Player_Dreamworld")
		if player and player.has_method("activate_crouching"):
			player.activate_crouching()
			print("Crouching für Spieler aktiviert!")
	elif event_name == "wake_up":
		print("Dialogic Event 'wake_up' empfangen! Wechsel zur Realwelt...")
		_wake_up_transition()
		
func _wake_up_transition() -> void:
	# Spieler von der Dreamworld entfernen
	var player = get_node_or_null("Player_Dreamworld")
	if player and player.has_method("cutscene_end"):
		player.cutscene_end()

	if player:
		player.queue_free()  # Dreamworld-Player löschen

	# Player-Referenz zurücksetzen, damit RealworldScenes den realen Player lädt
	GlobalScript.player = null
	GlobalScript.previous_scene = "dreamworld_tutorial"

	var blink_overlay = preload("res://scenes/components/blink_overlay.tscn").instantiate()
	get_tree().root.add_child(blink_overlay)

	var blink_rect = blink_overlay.get_node("Blink_Overlay")

	# Warten bis die Animation fertig ist, dann Szene wechseln
	await blink_rect.play_sleep_wake_nosound("res://scenes/realworld_home.tscn")
