extends Node2D

@onready var miniboss = $Miniboss
@onready var enemy_gate = $Enemy_Defeat_Gate
@onready var drop_manager: Node = $Drop_Manager

@onready var ghost_enemy_1: Ghost = $Ghost_Enemy_1
@onready var enemy_platform: TileMapLayer = $Enemy_Defeat_Platform
@onready var key_visuals_defeat: Node2D = $KeyVisuals_defeat
@onready var key_visuals_2: Node2D = $KeyVisuals2

#Muss noch hinzugefügt werden, TileMap soll wie bei enemy_gate verschwinden, 
# wenn nicht alle Keys erhalten
@onready var not_all_keys: TileMapLayer = $Not_all_keys
@export var math_no_key_timeline: String = "math_no_keys_timeline"
@onready var not_all_keys_area: Area2D = $NOT_ALL_KEYS_AREA

var cutscene_no_keys_played := false

@onready var question_label = $math_question
@onready var answer_labels = [
	$answer1,
	$answer2,
	$answer3
]

@onready var answer_areas = [
	$Area2D_Answer1,
	$Area2D_Answer2,
	$Area2D_Answer3
]

@export var teleport_target: Marker2D

@onready var paths = [
	$Path1,
	$Path2,
	$Path3
]

var tasks = [
	{"question": "What is 43 + 17 - 8?", "solution": 52},
	{"question": "What is 12 + 9?", "solution": 21},
	{"question": "What is 30 - 6 + 4?", "solution": 28}
]

func _ready():
	Dialogic.signal_event.connect(Callable(self, "_on_dialogic_signal"))
	randomize()
	setup_question()
	MusicManager.playMusic(MusicManager.MusicType.MATHE)
	
	not_all_keys_area.body_entered.connect(_on_not_all_keys_body_entered)
	
	# --- WICHTIG: Hier beobachten wir, wann der Miniboss verschwindet ---
	if miniboss:
		miniboss.tree_exited.connect(_on_miniboss_defeated)
	
	enemy_platform.collision_enabled = false
	if ghost_enemy_1:
		ghost_enemy_1.tree_exited.connect(_on_ghost_enemy_1_defeated)	
	
	for i in range(3):
		answer_areas[i].body_entered.connect(
			func(body): _on_answer_area_entered(i, body)
		)

func _on_answer_area_entered(index: int, body: Node2D) -> void:
	if not body.has_method("player"):
		return

	var is_correct = paths[index].visible

	if not is_correct:
		# Teleport zuerst! Deferred, damit Physics nicht blockiert
		if teleport_target:
			body.call_deferred("set_global_position", teleport_target.global_position)

		# HIER MUSS DER SPIELER 10 SCHADEN BEKOMMEN. BITTE REINMACHEN DANKE
		# Er bekommt den Tick, aber es wird nichts abgezogen oder sonst etwas. No clue
		if body.has_method("received_damage"):
			if body.has_method("health") and body.health != null:
				body.health.set_immortality(false)
			body.received_damage(10, answer_areas[index].global_position)

		# Frage neu randomisieren deferred
		call_deferred("setup_question")
	else:
		if teleport_target:
			body.call_deferred("set_global_position", teleport_target.global_position)



func setup_question():
	var task = tasks.pick_random()
	question_label.text = task.question

	var answers = generate_answers(task.solution)

	for i in range(3):
		answer_labels[i].text = str(answers[i])

	activate_correct_path(answers, task.solution)
	
func generate_answers(correct: int) -> Array:
	var answers = [correct]

	while answers.size() < 3:
		var fake = correct + randi_range(-10, 10)
		if fake != correct and fake not in answers:
			answers.append(fake)

	answers.shuffle()
	return answers

func activate_correct_path(answers: Array, correct: int):
	for i in range(3):
		var is_correct = answers[i] == correct

		# Path
		paths[i].visible = is_correct
		paths[i].collision_enabled = is_correct

		# Answer-Area
		answer_areas[i].monitoring = not is_correct
		answer_areas[i].monitorable = not is_correct

func _on_fall_damage_body_entered(body: Node2D) -> void:
	if not body.has_method("player"):
		return

	# Spieler sofort teleportieren zu festen Koordinaten
	# Deferred, damit Physics-Signal nicht blockiert wird
	body.call_deferred("set_global_position", Vector2(650, 560))


func _on_fall_damage_2_body_entered(body: Node2D) -> void:
	if not body.has_method("player"):
		return

	# Spieler sofort teleportieren zu festen Koordinaten
	# Deferred, damit Physics-Signal nicht blockiert wird
	body.call_deferred("set_global_position", Vector2(3619, 241))

func _on_miniboss_defeated():
	print("Miniboss ist tot - Gate öffnet sich!")

	if not enemy_gate:
		return

	#GATE OPEN Sound?! plz

	# Visuell ausblenden
	enemy_gate.visible = false

	# Kollision des TileMapLayer komplett deaktivieren
	enemy_gate.collision_enabled = false
	
func _on_ghost_enemy_1_defeated():
	print("Geist ist tot - Plattform erscheint!")

	if not enemy_platform:
		return

	# Visuell einblenden
	enemy_platform.visible = true
	key_visuals_defeat.visible = true
	key_visuals_2.visible = true

	# Kollision des TileMapLayer aktivieren
	enemy_platform.collision_enabled = true


func _on_fall_damage_3_body_entered(body: Node2D) -> void:
	if not body.has_method("player"):
		return

	# Spieler sofort teleportieren zu festen Koordinaten
	# Deferred, damit Physics-Signal nicht blockiert wird
	body.call_deferred("set_global_position", Vector2(531, -170))


func _on_not_all_keys_body_entered(body: Node2D) -> void:
	if not body.has_method("player"):
		return

	# Cutscene nur einmal
	if cutscene_no_keys_played:
		return
	cutscene_no_keys_played = true
	_start_cutscene(body, math_no_key_timeline)

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
	elif event_name == "go_home":
		print("Dialogic Event 'go_home' empfangen!")

		# Not_all_keys TileMapLayer deaktivieren (wie Gate)
		if not_all_keys:
			not_all_keys.visible = false
			not_all_keys.collision_enabled = false

		# Optional: Area deaktivieren, damit nichts mehr triggert
		if not_all_keys_area:
			not_all_keys_area.monitoring = false
			not_all_keys_area.monitorable = false
