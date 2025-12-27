extends Area2D
class_name QuestTrigger

@export var quest: QuestData
@export var auto_start_dialog: String = ""
@export var trigger_once: bool = true

var already_triggered := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	already_triggered = SaveManager.get_quest_already_triggered(quest.id)

func _on_body_entered(body):
	if not (body is PlayerRealworld):
		return

	if trigger_once and already_triggered:
		return

	already_triggered = true
	SaveManager.set_quest_triggered(quest.id)

	# 1. Quest aktivieren
	if quest:
		QuestManager.set_quest(quest)

	# 2. Spieler einfrieren (cutscene starten)
	if body.has_method("cutscene_start"):
		body.cutscene_start()

	# 3. Dialog starten
	if auto_start_dialog != "":
		Dialogic.start(auto_start_dialog)
