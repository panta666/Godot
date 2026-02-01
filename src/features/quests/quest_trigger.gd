extends Area2D
class_name QuestTrigger

@export var quest: QuestData
@export var auto_start_dialog: String = ""
@export var trigger_once: bool = true

@export var enabled: bool = true
var already_triggered := false


func _ready() -> void:
	# Nur einmal verbinden (falls im Editor auch verbunden wurde)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	# Null-sicher (falls quest nicht gesetzt ist)
	if quest:
		already_triggered = SaveManager.get_quest_already_triggered(quest.id)

	_apply_enabled_state()


func set_enabled(v: bool) -> void:
	enabled = v
	_apply_enabled_state()


func _apply_enabled_state() -> void:
	# Wenn aus: keine Events, keine Kollision
	monitoring = enabled
	monitorable = enabled

	var cs := get_node_or_null("CollisionShape2D")
	if cs:
		cs.disabled = not enabled


func _on_body_entered(body: Node) -> void:
	# <-- DER WICHTIGE GUARD
	if not enabled:
		return

	if not (body is PlayerRealworld):
		return

	if trigger_once and already_triggered:
		return

	already_triggered = true

	if quest:
		QuestManager.trigger_quest(quest)

	# Spieler einfrieren (Cutscene starten)
	if body.has_method("cutscene_start"):
		body.cutscene_start()

	# Dialog starten
	if auto_start_dialog != "":
		Dialogic.start(auto_start_dialog)
