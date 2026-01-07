extends Node
class_name Quest_Manager

signal quest_changed(quest: QuestData)

var current_quest: QuestData
var all_quests: Array[QuestData] = []

@export var quest_folder: String = "res://resources/quests"

func _ready():
	_load_all_quests()
	Dialogic.signal_event.connect(_on_dialogic_signal)

# --- Handler für Dialogic Signale ---
func _on_dialogic_signal(signal_name: String):
	if all_quests.is_empty():
		return

	for quest in all_quests:
		if quest is QuestData and quest.dialog_signal == signal_name:
			# Bereits getriggert?
			if SaveManager.get_quest_already_triggered(quest.id):
				return

			print("[QuestManager] Starte Quest via Dialogic:", quest.id)
			set_quest(quest)
			SaveManager.set_quest_triggered(quest.id)

			# Szeneeffekte direkt anwenden
			_apply_scene_effects_for_completed_quest(quest)
			return

# --- Wendet Szeneeffekte aller bereits getriggerten Quests an ---
func _apply_all_completed_quests_effects():
	for quest in all_quests:
		if SaveManager.get_quest_already_triggered(quest.id):
			_apply_scene_effects_for_completed_quest(quest)

	# --- Zusätzlich alle NPCs prüfen, ob gespeicherte Effekte vorhanden sind ---
	var scene_name = get_tree().current_scene.name
	var scene_effects = SaveManager.get_scene_effects(scene_name)

	for npc_name in scene_effects.keys():
		var npc_node = get_tree().current_scene.get_node_or_null(npc_name)
		if not npc_node or not npc_node.npc_data:
			continue

		var data = scene_effects[npc_name]

		# Anwenden von can_sit & sit_direction
		if "can_sit" in data:
			npc_node.npc_data.can_sit = data["can_sit"]
		if "sit_direction" in data:
			npc_node.npc_data.sit_direction = data["sit_direction"]
		if "dialog_timeline_path" in data:
			npc_node.npc_data.dialog_timeline_path = data["dialog_timeline_path"]

		# Wendet die Animation an, wenn NPC sitzen soll
		if npc_node.has_method("apply_npc_data"):
			npc_node.apply_npc_data()

# --- Wendet alle Szenenänderungen für eine bestimmte Quest an ---
func _apply_scene_effects_for_completed_quest(quest: QuestData) -> void:
	var scene_name = get_tree().current_scene.name

	# Effekte nur für die Quest-ID
	match quest.id:
		"4":
			await FadeTransition.fade_out(1.0)
			
			var prof_node = get_tree().current_scene.get_node_or_null("BlinkingProf")
			if prof_node:
				prof_node.visible = false
				SaveManager.add_scene_effect(scene_name, "BlinkingProf", "visible", false)

			var blinking_chair = get_tree().current_scene.get_node_or_null("BlinkingChair")
			if blinking_chair:
				blinking_chair.visible = true
				SaveManager.add_scene_effect(scene_name, "BlinkingChair", "visible", true)
			
			
			# --- NPCs Sitz/Position/Z-Index/Dialogic ---
			var npcs_to_update := {
				"NPC12": {"pos": Vector2(250, 184), "z": 3, "sit_dir": NPCData.SitDirection.RIGHT, "timeline": "res://dialogs/npc12.tres"},
				"NPC11": {"pos": Vector2(186, 152), "z": 3, "sit_dir": NPCData.SitDirection.RIGHT, "timeline": "res://dialogs/npc11.tres"},
				"NPC4":  {"pos": Vector2(250, 249), "z": 3, "sit_dir": NPCData.SitDirection.RIGHT, "timeline": "res://dialogs/npc4.tres"},
				"NPC10": {"pos": Vector2(250, 280), "z": 3, "sit_dir": NPCData.SitDirection.RIGHT, "timeline": "res://dialogs/npc10.tres"},
				"NPC9":  {"pos": Vector2(313, 248), "z": 3, "sit_dir": NPCData.SitDirection.RIGHT, "timeline": "res://dialogs/npc9.tres"},
				"NPC6":  {"pos": Vector2(442, 152), "z": 3, "sit_dir": NPCData.SitDirection.RIGHT, "timeline": "res://dialogs/npc6.tres"},
				"NPC5":  {"pos": Vector2(441, 216), "z": 3, "sit_dir": NPCData.SitDirection.RIGHT, "timeline": "res://dialogs/npc5.tres"},
			}

			for npc_name in npcs_to_update.keys():
				var npc_node = get_tree().current_scene.get_node_or_null(npc_name)
				if npc_node:
					var data = npcs_to_update[npc_name]

					# --- Position + Z-Index ---
					npc_node.global_position = data.pos
					npc_node.z_index = data.z

					# --- NPCData anpassen ---
					if npc_node.npc_data:
						npc_node.npc_data.can_sit = true
						npc_node.npc_data.sit_direction = data.sit_dir

						# Optional: Dialogic-Timeline überschreiben
						if "timeline" in data and data.timeline != "":
							npc_node.npc_data.dialog_timeline_path = data.timeline

						if npc_node.has_method("apply_npc_data"):
							npc_node.apply_npc_data()

					# --- Persistent speichern ---
					SaveManager.add_scene_effect(scene_name, npc_name, "position", data.pos)
					SaveManager.add_scene_effect(scene_name, npc_name, "z_index", data.z)
					SaveManager.add_scene_effect(scene_name, npc_name, "can_sit", true)
					SaveManager.add_scene_effect(scene_name, npc_name, "sit_direction", data.sit_dir)
					SaveManager.add_scene_effect(scene_name, npc_name, "dialog_timeline_path", data.timeline)

			await FadeTransition.fade_in(1.0)

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
