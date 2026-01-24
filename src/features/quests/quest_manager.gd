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
		if quest.dialog_signal == signal_name:
			trigger_quest(quest)
			return

# --- Wendet Szeneeffekte aller bereits getriggerten Quests an ---
func _apply_all_completed_quests_effects():
	for quest in all_quests:
		if SaveManager.get_quest_already_triggered(quest.id):
			_apply_scene_effects_for_completed_quest(quest)

	var scene_name = get_tree().current_scene.name
	var scene_effects = SaveManager.get_scene_effects(scene_name)

	for npc_name in scene_effects.keys():
		var npc_node = get_tree().current_scene.get_node_or_null(npc_name)
		if not npc_node:
			continue

		var data = scene_effects[npc_name]

		# --- Sichtbarkeit (für NPCs, Chairs, Overlays, etc.) ---
		if "visible" in data:
			npc_node.visible = data["visible"]

		# --- Farbe (PointLight2D, ColorRect, Sprite2D etc.) ---
		if "color" in data and npc_node.has_property("color"):
			npc_node.color = data["color"]

		# --- NPC-spezifische Daten ---
		if npc_node.has_variable("npc_data") and npc_node.npc_data:
			if "can_sit" in data:
				npc_node.npc_data.can_sit = data["can_sit"]
			if "sit_direction" in data:
				npc_node.npc_data.sit_direction = data["sit_direction"]
			if "dialog_timeline_path" in data:
				npc_node.npc_data.dialog_timeline_path = data["dialog_timeline_path"]

			if npc_node.has_method("apply_npc_data"):
				npc_node.apply_npc_data()

# --- Wendet alle Szenenänderungen für eine bestimmte Quest an ---
func _apply_scene_effects_for_completed_quest(quest: QuestData) -> void:
	var scene_name = get_tree().current_scene.name

	match quest.id:
		"3":
			# Tür sperren
			var door_node = get_tree().current_scene.get_node_or_null("Door")
			if door_node and door_node.has_method("lock"):
				door_node.lock()
				SaveManager.lock_door(door_node.door_id)
		
		"4":
			await FadeTransition.fade_out(1.0)
			
			print("Quest 4 abgeschlossen -> Chair freischalten")
			SaveManager.save_data["game_progress"]["chair_unlocked"] = true
			SaveManager.save_game()
			SaveManager.emit_signal("chair_unlocked_signal")
			var chair_node = get_tree().current_scene.get_node_or_null("Chair")
			if chair_node:
				chair_node.interactable.is_interactable = true
				if chair_node.has_method("update_interact_text"):
					chair_node.update_interact_text()
			
			var prof_node = get_tree().current_scene.get_node_or_null("BlinkingProf")
			if prof_node:
				prof_node.visible = false
				SaveManager.add_scene_effect(scene_name, "BlinkingProf", "visible", false)

			var blinking_chair = get_tree().current_scene.get_node_or_null("BlinkingChair")
			if blinking_chair:
				blinking_chair.visible = true
				SaveManager.add_scene_effect(scene_name, "BlinkingChair", "visible", true)

			# --- NPCs aktualisieren ---
			var npcs_to_update := {
				"NPC12": {"pos": Vector2(250, 184), "z": 3, "sit_dir": NPCData.SitDirection.RIGHT},
				"NPC11": {"pos": Vector2(186, 152), "z": 3, "sit_dir": NPCData.SitDirection.RIGHT},
				"NPC4":  {"pos": Vector2(250, 249), "z": 3, "sit_dir": NPCData.SitDirection.RIGHT},
				"NPC10": {"pos": Vector2(250, 280), "z": 3, "sit_dir": NPCData.SitDirection.RIGHT},
				"NPC9":  {"pos": Vector2(313, 248), "z": 3, "sit_dir": NPCData.SitDirection.RIGHT},
				"NPC6":  {"pos": Vector2(442, 152), "z": 3, "sit_dir": NPCData.SitDirection.RIGHT},
				"NPC5":  {"pos": Vector2(441, 216), "z": 3, "sit_dir": NPCData.SitDirection.RIGHT},
				"NPC2":  {"timeline": "res://src/features/dialogue/dahm_timeline_two.dtl"}
			}

			for npc_name in npcs_to_update.keys():
				var npc_node = get_tree().current_scene.get_node_or_null(npc_name)
				if not npc_node or not npc_node.npc_data:
					continue

				var data = npcs_to_update[npc_name]

				# --- Position anwenden, falls vorhanden ---
				if "pos" in data:
					npc_node.global_position = data["pos"]
					SaveManager.add_scene_effect(scene_name, npc_name, "position", data["pos"])

				# --- Z-Index anwenden, falls vorhanden ---
				if "z" in data:
					npc_node.z_index = data["z"]
					SaveManager.add_scene_effect(scene_name, npc_name, "z_index", data["z"])

				# --- Sitzrichtung anwenden, falls vorhanden ---
				if "sit_dir" in data:
					npc_node.npc_data.can_sit = true
					npc_node.npc_data.sit_direction = data["sit_dir"]
					SaveManager.add_scene_effect(scene_name, npc_name, "can_sit", true)
					SaveManager.add_scene_effect(scene_name, npc_name, "sit_direction", data["sit_dir"])

				# --- Timeline überschreiben, falls vorhanden ---
				if "timeline" in data and data["timeline"] != "":
					npc_node.npc_data.dialog_timeline_path = data["timeline"]
					SaveManager.add_scene_effect(scene_name, npc_name, "dialog_timeline_path", data["timeline"])

				# --- NPC-Daten anwenden ---
				if npc_node.has_method("apply_npc_data"):
					npc_node.apply_npc_data()

			await FadeTransition.fade_in(1.0)
		"5":
			# Stuhl deaktivieren / sperren
			print("Quest 5 abgeschlossen -> Chair sperren")
			SaveManager.save_data["game_progress"]["chair_unlocked"] = false
			SaveManager.save_game()
	
			SaveManager.emit_signal("chair_unlocked_signal")
			var chair_node = get_tree().current_scene.get_node_or_null("Chair")
			if chair_node:
				chair_node.interactable.is_interactable = false
				if chair_node.has_method("update_interact_text"):
					chair_node.update_interact_text()
			
			var blinking_chair = get_tree().current_scene.get_node_or_null("BlinkingChair")
			if blinking_chair:
				blinking_chair.visible = false
				SaveManager.add_scene_effect(scene_name, "BlinkingChair", "visible", false)
			
			var prof_node = get_tree().current_scene.get_node_or_null("BlinkingProf")
			if prof_node:
				prof_node.visible = true
				SaveManager.add_scene_effect(scene_name, "BlinkingProf", "visible", true)
			
			# NPC2 Timeline ändern
			var npc2_node = get_tree().current_scene.get_node_or_null("NPC2")
			if npc2_node and npc2_node.npc_data:
				npc2_node.npc_data.dialog_timeline_path = "res://src/features/dialogue/dahm_timeline_three.dtl"
				SaveManager.add_scene_effect(get_tree().current_scene.name, "NPC2", "dialog_timeline_path", npc2_node.npc_data.dialog_timeline_path)
		
			# NPC2 aktualisieren, falls Methode vorhanden
			if npc2_node.has_method("apply_npc_data"):
				npc2_node.apply_npc_data()
		
		"6":
			#Shop freischalten in Realworld
			SaveManager.unlock_shop()
			SaveManager.save_game()
			
			var prof_node = get_tree().current_scene.get_node_or_null("BlinkingProf")
			if prof_node:
				prof_node.visible = false
				SaveManager.add_scene_effect(scene_name, "BlinkingProf", "visible", false)
				
			var shop_node = get_tree().current_scene.get_node_or_null("BlinkingShop")
			if shop_node:
				shop_node.visible = true
				SaveManager.add_scene_effect(scene_name, "BlinkingShop", "visible", true)
				
			# NPC2 Timeline ändern
			var npc2_node = get_tree().current_scene.get_node_or_null("NPC2")
			if npc2_node and npc2_node.npc_data:
				npc2_node.npc_data.dialog_timeline_path = "res://src/features/dialogue/dahm_timeline_four.dtl"
				SaveManager.add_scene_effect(get_tree().current_scene.name, "NPC2", "dialog_timeline_path", npc2_node.npc_data.dialog_timeline_path)
		
			# NPC2 aktualisieren, falls Methode vorhanden
			if npc2_node.has_method("apply_npc_data"):
				npc2_node.apply_npc_data()
		
		"7":
			# Stuhl wieder freischalten
			print("Quest 6 abgeschlossen -> Chair freischalten")
			SaveManager.save_data["game_progress"]["chair_unlocked"] = true
			SaveManager.save_game()
			SaveManager.emit_signal("chair_unlocked_signal")
			var chair_node = get_tree().current_scene.get_node_or_null("Chair")
			if chair_node:
				chair_node.interactable.is_interactable = true
				if chair_node.has_method("update_interact_text"):
					chair_node.update_interact_text()
					
			var shop_node = get_tree().current_scene.get_node_or_null("BlinkingShop")
			if shop_node:
				shop_node.visible = false
				SaveManager.add_scene_effect(scene_name, "BlinkingShop", "visible", false)
			
			var blinking_chair = get_tree().current_scene.get_node_or_null("BlinkingChair")
			if blinking_chair:
				blinking_chair.visible = false
				SaveManager.add_scene_effect(scene_name, "BlinkingChair", "visible", false)
		"8":
			SaveManager.update_current_scene()
			# --- Sonnenlicht anpassen ---
			var sunlight = get_tree().current_scene.get_node_or_null("Sunlight")
			if sunlight and sunlight is PointLight2D:
				var sunset_color := Color(1.0, 0.75, 0.45)
				sunlight.color = sunset_color
				SaveManager.add_scene_effect(scene_name, "Sunlight", "color", sunset_color)

			# --- Sunset Overlay anzeigen ---
			var sunset_rect = get_tree().current_scene.get_node_or_null("Sunset")
			if sunset_rect:
				sunset_rect.visible = true
				SaveManager.add_scene_effect(scene_name, "Sunset", "visible", true)
			
			
			# OOP Türe wieder öffnen
			SaveManager.unlock_door("realworld_oop_door_inside")
			SaveManager.unlock_door("realworld_math_door")
			
			# --- NPCs aktualisieren ---
			var npcs_to_hide := [
				"NPC12",
				"NPC11",
				"NPC4",
				"NPC10",
				"NPC9",
				"NPC6",
				"NPC5",
				"NPC2"
			]

			for npc_name in npcs_to_hide:
				var npc_node = get_tree().current_scene.get_node_or_null(npc_name)
				if not npc_node:
					continue

				npc_node.visible = false
				SaveManager.add_scene_effect(scene_name, npc_name, "visible", false)
		"9":
			# --- Sonnenuntergang (mehrere Lichter) ---
			var sunset_color := Color(1.0, 0.75, 0.45)

			# Alle Sunlight-Nodes einfärben
			var sunlight_names := [
				"Sunlight",
				"Sunlight2",
				"Sunlight3",
				"Sunlight4",
				"Sunlight5"
			]

			for light_name in sunlight_names:
				var light_node = get_tree().current_scene.get_node_or_null(light_name)
				if light_node and light_node is PointLight2D:
					light_node.color = sunset_color
					SaveManager.add_scene_effect(scene_name, light_name, "color", sunset_color)

			# --- Sunset Overlay anzeigen ---
			var sunset_rect = get_tree().current_scene.get_node_or_null("Sunset")
			if sunset_rect:
				sunset_rect.visible = true
				SaveManager.add_scene_effect(scene_name, "Sunset", "visible", true)
				
			var blinking_oop = get_tree().current_scene.get_node_or_null("BlinkingOOP")
			if blinking_oop:
				blinking_oop.visible = false
				SaveManager.add_scene_effect(scene_name, "BlinkingOOP", "visible", false)
				
			var blinking_math = get_tree().current_scene.get_node_or_null("BlinkingMath")
			if blinking_math:
				blinking_math.visible = true
				SaveManager.add_scene_effect(scene_name, "BlinkingOOP", "visible", true)
				
		"10":
			# Tür sperren
			var door_node = get_tree().current_scene.get_node_or_null("Door")
			if door_node and door_node.has_method("lock"):
				door_node.lock()
				SaveManager.lock_door(door_node.door_id)
			
			# Stuhl deaktivieren / sperren
			print("Quest 5 abgeschlossen -> Chair sperren")
			SaveManager.save_data["game_progress"]["chair_unlocked"] = false
			SaveManager.save_game()
	
			SaveManager.emit_signal("chair_unlocked_signal")
			var chair_node = get_tree().current_scene.get_node_or_null("Chair")
			if chair_node:
				chair_node.interactable.is_interactable = false
				if chair_node.has_method("update_interact_text"):
					chair_node.update_interact_text()
					
		"11":
			# Chair wieder freischalten
			print("Quest 11 abgeschlossen -> Chair freischalten")

			SaveManager.save_data["game_progress"]["chair_unlocked"] = true
			SaveManager.save_game()
			SaveManager.emit_signal("chair_unlocked_signal")
			
			GlobalScript.unlock_level(GlobalScript.classrooms.mathe, 1)

			var chair_node = get_tree().current_scene.get_node_or_null("Chair")
			if chair_node:
				chair_node.interactable.is_interactable = true
				if chair_node.has_method("update_interact_text"):
					chair_node.update_interact_text()
					
			var blinking_chair = get_tree().current_scene.get_node_or_null("BlinkingChair")
			if blinking_chair:
				blinking_chair.visible = true
				SaveManager.add_scene_effect(scene_name, "BlinkingChair", "visible", true)
				
			var blinking_prof = get_tree().current_scene.get_node_or_null("BlinkingProf")
			if blinking_prof:
				blinking_prof.visible = false
				SaveManager.add_scene_effect(scene_name, "BlinkingProf", "visible", false)

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
	
func trigger_quest(quest: QuestData):
	if SaveManager.get_quest_already_triggered(quest.id):
		return

	print("[QuestManager] Quest getriggert:", quest.id)
	set_quest(quest)
	SaveManager.set_quest_triggered(quest.id)

	# Wendet die Szeneeffekte an (z.B. Tür lock/unlock)
	_apply_scene_effects_for_completed_quest(quest)
