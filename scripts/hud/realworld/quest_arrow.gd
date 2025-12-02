extends Node2D

@export var min_distance: float = 50.0
@export var max_distance: float = 800.0

var arrow_sprite: Sprite2D
var player: Node2D
var target: Node2D

func _ready() -> void:
	# Nichts crashen, wenn Spieler oder Sprite noch nicht existieren
	arrow_sprite = $ArrowSprite if has_node("ArrowSprite") else null
	if not arrow_sprite:
		push_warning("QuestArrow: Kein ArrowSprite gefunden!")
	
	player = get_parent() # Spieler ist Parent
	if not player:
		# Spieler existiert noch nicht Pfeil einfach unsichtbar lassen
		if arrow_sprite:
			arrow_sprite.visible = false

func _process(_delta: float) -> void:
	# Prüfen, ob alles existiert
	if not player:
		print("[QuestArrow] Spieler existiert noch nicht!")
		if arrow_sprite:
			arrow_sprite.visible = false
		return

	if not target:
		print("[QuestArrow] Ziel wurde noch nicht gesetzt!")
		if arrow_sprite:
			arrow_sprite.visible = false
		return

	if not arrow_sprite:
		print("[QuestArrow] ArrowSprite existiert nicht!")
		return

	# Aktuelle Szenen prüfen
	var player_scene = player.get_tree().current_scene
	var target_scene = target.get_tree().current_scene
	print("[QuestArrow] Spieler in Szene:", player_scene.name if player_scene else "null")
	print("[QuestArrow] Ziel in Szene:", target_scene.name if target_scene else "null")

	if player_scene != target_scene:
		print("[QuestArrow] Spieler und Ziel sind in unterschiedlichen Szenen. Pfeil wird ausgeblendet.")
		arrow_sprite.visible = false
		return
	else:
		arrow_sprite.visible = true

	# Richtung und Distanz berechnen
	var dir = target.global_position - player.global_position
	var dist = dir.length()
	print("[QuestArrow] Richtung zum Ziel:", dir, "Entfernung:", dist)

	# Pfeil-Rotation
	rotation = dir.angle() - deg_to_rad(90)  # ggf. anpassen je nach Pfeil
	print("[QuestArrow] Pfeil-Rotation (rad):", rotation)

	# Farbe anhand Distanz
	var t = clamp((dist - min_distance) / (max_distance - min_distance), 0.0, 1.0)
	arrow_sprite.modulate = Color(lerp(0, 1, t), lerp(1, 0, t), 0)
	print("[QuestArrow] Pfeil-Farbe modulate:", arrow_sprite.modulate)


func set_target(new_target: Node2D) -> void:
	target = new_target
