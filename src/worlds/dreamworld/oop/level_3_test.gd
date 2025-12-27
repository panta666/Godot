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

	# Level 2 für OOP freischalten
	GlobalScript.oop_level_unlocked[2] = true
	
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
	GlobalScript.change_scene("realworld_classroom_one")
