extends Node
class_name Quest_Manager

signal quest_changed(quest: QuestData)

var current_quest: QuestData
var all_quests: Array[QuestData] = []

@export var quest_folder: String = "res://resources/quests"

func _ready():
	_load_all_quests()
	Dialogic.signal_event.connect(_on_dialogic_signal)

	# Bereits getriggerte Quests → Szeneeffekte anwenden
	call_deferred("_apply_all_completed_quests_effects")

# --- Handler für Dialogic Signale ---
func _on_dialogic_signal(signal_name: String):
	if all_quests.is_empty():
		return

	for quest in all_quests:
		if quest is QuestData:
			if quest.dialog_signal != "" and quest.dialog_signal == signal_name:
				# Bereits getriggert?
				if SaveManager.get_quest_already_triggered(quest.id):
					return

				print("[QuestManager] Starte Quest via Dialogic:", quest.id)
				set_quest(quest)
				SaveManager.set_quest_triggered(quest.id)

				# Szeneffekte direkt anwenden
				_apply_scene_effects_for_completed_quest(quest)
				return

func _apply_all_completed_quests_effects():
	for quest in all_quests:
		if SaveManager.get_quest_already_triggered(quest.id):
			_apply_scene_effects_for_completed_quest(quest)

# --- Wendet alle Szenenänderungen für eine bestimmte Quest an ---
func _apply_scene_effects_for_completed_quest(quest: QuestData) -> void:
	match quest.id:
		"4":
			var prof_node = get_tree().current_scene.get_node_or_null("BlinkingProf")
			if prof_node:
				prof_node.visible = false
			var blinking_chair = get_tree().current_scene.get_node_or_null("BlinkingChair")
			if blinking_chair:
				blinking_chair.visible = true
			var chair = get_tree().current_scene.get_node_or_null("Chair")
			if chair:
				chair.visible = true

# --- Lädt alle QuestData .tres aus dem Ordner ---
func _load_all_quests():
	var dir = DirAccess.open(quest_folder)
	if not dir:
		push_error("Quest folder not found: " + quest_folder)
		return

	dir.list_dir_begin()
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var res = load(quest_folder + "/" + file)
			var quest_data = res as QuestData
			if quest_data:
				all_quests.append(quest_data)
				print("[QuestManager] Geladene Quest:", quest_data.id)
			else:
				print("[QuestManager] Ignoriere Datei (kein QuestData):", file)
		file = dir.get_next()

func set_quest(quest: QuestData) -> void:
	current_quest = quest
	emit_signal("quest_changed", quest)

func clear_quest() -> void:
	current_quest = null
	emit_signal("quest_changed", null)
