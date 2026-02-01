extends Node2D

@export var min_distance: float = 50.0
@export var max_distance: float = 800.0

var arrow_sprite: Sprite2D
var player: Node2D
var target: Node2D

var pulse_time: float = 0.0  # Für Animation

func _ready() -> void:
	arrow_sprite = $ArrowSprite if has_node("ArrowSprite") else null
	player = get_parent()
	
	QuestManager.quest_changed.connect(_on_quest_changed)

	if not player and arrow_sprite:
		arrow_sprite.visible = false


func _process(delta: float) -> void:
	if not player or not target or not arrow_sprite:
		if arrow_sprite:
			arrow_sprite.visible = false
		return

	# Szene prüfen
	if player.get_tree().current_scene != target.get_tree().current_scene:
		arrow_sprite.visible = false
		return
	else:
		arrow_sprite.visible = true

	# Richtung & Distanz
	var dir = target.global_position - player.global_position
	var dist = dir.length()

	rotation = dir.angle() - deg_to_rad(90)

	# ---- Farbverlauf: Nah = grün, weit = rot ----
	var t = clamp((dist - min_distance) / (max_distance - min_distance), 0.0, 1.0)
	var r = lerp(0.0, 1.0, t)
	var g = lerp(1.0, 0.0, t)
	arrow_sprite.modulate = Color(r, g, 0.0, 1.0)

	# ---- Puls-Effekt ----
	pulse_time += delta * 4.0
	var pulse = 0.2 + sin(pulse_time) * 0.01
	arrow_sprite.scale = Vector2(pulse, pulse)

	# ---- Glow-Effekt ----
	arrow_sprite.self_modulate = Color(1,1,1,1) if dist < min_distance * 3 else Color(0.9,0.9,0.9,1)

	# ---- Alpha für sehr weit ----
	arrow_sprite.modulate.a = 0.7 + sin(pulse_time) * 0.3 if dist > max_distance * 0.9 else 1.0

	# ---- Ziel erreicht ----
	if dist <= min_distance:
		arrow_sprite.visible = false
		target = null
		_complete_quest()


func _on_quest_changed(quest: QuestData) -> void:
	if quest == null or quest.target_node_path == "":
		target = null
		print("[QuestArrow] Keine Quest aktiv")
		if arrow_sprite:
			arrow_sprite.visible = false
		return

	var root = get_tree().current_scene
	print("[QuestArrow] Aktuelle Szene:", root.name)
	print("[QuestArrow] Quest-Ziel-Szene:", quest.target_scene)
	print("[QuestArrow] Ziel-Pfad:", quest.target_node_path)

	if root.name != quest.target_scene:
		target = null
		print("[QuestArrow] Zielszene stimmt nicht, Arrow ausgeblendet")
		if arrow_sprite:
			arrow_sprite.visible = false
		return

	var node = root.get_node_or_null(quest.target_node_path)
	target = node
	print("[QuestArrow] Gefundene Node:", node)


func _complete_quest() -> void:
	var hud = get_tree().root.get_node_or_null("QuestHud")
	if hud:
		var tween = Tween.new()
		hud.add_child(tween)
		
		# Erst kurz aufleuchten
		tween.tween_property(hud, "modulate", Color(1,1,0,1), 0.2)
		# Danach ausblenden
		tween.tween_property(hud, "modulate", Color(1,1,1,0), 0.3)
		
		tween.start()
		tween.connect("finished", Callable(self, "_clear_quest_hud"))
	else:
		_clear_quest_hud()


func _clear_quest_hud() -> void:
	QuestManager.clear_quest()
