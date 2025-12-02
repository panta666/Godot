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

	if not player and arrow_sprite:
		arrow_sprite.visible = false


func _process(delta: float) -> void:
	if not player or not target or not arrow_sprite:
		if arrow_sprite: arrow_sprite.visible = false
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

	# ---- Größenanimation (Puls-Effekt) ----
	pulse_time += delta * 4.0  # Geschwindigkeit
	var pulse = 0.2 + sin(pulse_time) * 0.01
	arrow_sprite.scale = Vector2(pulse, pulse)

	# ---- Glow-Effekt, wenn sehr nah ----
	if dist < min_distance * 3:
		arrow_sprite.self_modulate = Color(1.0, 1.0, 1.0, 1.0) # heller
	else:
		arrow_sprite.self_modulate = Color(0.9, 0.9, 0.9, 1.0)

	# ---- optional: Blinken wenn extrem weit ----
	if dist > max_distance * 0.9:
		arrow_sprite.modulate.a = 0.7 + sin(pulse_time) * 0.3
	else:
		arrow_sprite.modulate.a = 1.0

	# ---- Ausblenden wenn direkt am Ziel ----
	if dist <= min_distance:
		arrow_sprite.visible = false


func set_target(new_target: Node2D) -> void:
	target = new_target
