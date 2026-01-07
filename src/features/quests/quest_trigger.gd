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

	if quest:
		# Direkt den Autoload verwenden
		QuestManager.trigger_quest(quest)

	# Spieler einfrieren (Cutscene starten)
	if body.has_method("cutscene_start"):
		body.cutscene_start()

	# Dialog starten
	if auto_start_dialog != "":
		Dialogic.start(auto_start_dialog)
