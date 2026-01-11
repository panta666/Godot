extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var player: CharacterBody2D = $"../Player_Dreamworld"

# KANN SPÄTER GELÖSCHT WERDEN IST NUR ZUM TEST GEWESEN!

func _ready():
	# Signal verbinden
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	# Prüfen, ob es der Spieler ist
	if body != player:
		return  # Nur Player löst das Event aus

	print("Level Two Bereich betreten! OOP Level 3 freischalten.")

	# Level 1 für Mathe freischalten
	GlobalScript.unlock_level(GlobalScript.classrooms.mathe, 1)
	
	# LevelUI aktualisieren, falls vorhanden
	var classroom = get_tree().current_scene
	if classroom.has_node("LevelUI"):
		var level_ui = classroom.get_node("LevelUI") as CanvasLayer
		# level_ui muss die unlock Funktion oder update_level_button nutzen
		if "unlock_oop_level" in level_ui:
			level_ui.unlock_oop_level(2)
		else:
			level_ui.update_level_button()

	# Zurück ins Klassenzimmer
	await _return_to_classroom()

func _return_to_classroom() -> void:
	# Kurze Wartezeit
	await get_tree().create_timer(0.2).timeout
	# Szenenwechsel zurück
		# Blink Overlay laden
	var blink_overlay = preload("res://src/shared/components/blink_overlay.tscn").instantiate()
	get_tree().root.add_child(blink_overlay)
	
	var overlay = blink_overlay.get_node("Blink_Overlay")
	await overlay.play_wake_up()
	GlobalScript.change_scene("realworld_classroom_one")
