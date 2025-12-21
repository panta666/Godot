extends Node2D

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
	randomize()
	setup_question()
	
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
	body.call_deferred("set_global_position", Vector2(2830, 127))
