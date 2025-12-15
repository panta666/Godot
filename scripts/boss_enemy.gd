extends "res://scripts/generic_enemy.gd"


func _on_health_depleted() -> void:
	healthbar._deplete()
	print("Level One Bereich betreten! OOP Level 2 freischalten.")

	# Level 2 für OOP freischalten
	GlobalScript.oop_level_unlocked[1] = true
	
	# LevelUI aktualisieren, falls vorhanden
	var classroom = get_tree().current_scene
	if classroom.has_node("LevelUI"):
		var level_ui = classroom.get_node("LevelUI") as CanvasLayer
		# level_ui muss die unlock Funktion oder update_level_button nutzen
		if "unlock_oop_level" in level_ui:
			level_ui.unlock_oop_level(1)
		else:
			level_ui.update_level_button()
			
	await _return_to_classroom()
	queue_free()

	
func _return_to_classroom() -> void:
	# Kurze Wartezeit
	await get_tree().create_timer(0.2).timeout
	print("change scene")
	# Szenenwechsel zurück
	GlobalScript.change_scene("realworld_classroom_one")
