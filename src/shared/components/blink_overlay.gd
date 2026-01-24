extends ColorRect

@export var max_blur_strength := 8.0
@export var first_blink_duration := 1.1   # Erstes Blinzeln langsamer
@export var second_blink_duration := 0.5  # Zweites Blinzeln schneller
@export var eyes_closed_hold := 0.5       # Zeit, in der die Augen geschlossen bleiben
@onready var mat := material
@onready var yawning_player: AudioStreamPlayer = $"../YawningPlayer"



func _ready():
	mat.set_shader_parameter("resolution", get_viewport_rect().size)
	mat.set_shader_parameter("blur_strength", 0.0)
	mat.set_shader_parameter("blink_progress", 0.0)
	visible = false

# ------------------------------------------------------
# Einschlafen + Aufwachen mit Blur gekoppelt
# ------------------------------------------------------
func play_sleep_wake(next_scene_path: String) -> void:
	GlobalScript.transition_scene = true
	visible = true
	
	yawning_player.play()
	
	# Erstes Blinzeln (langsamer)
	await animate_blink(first_blink_duration)

	# Zweites Blinzeln (schneller)
	await animate_blink(second_blink_duration)

	# Augen langsam schließen + Blur hoch
	await animate_shader("blink_progress", 0.0, 1.0, second_blink_duration)
	await animate_shader("blur_strength", 0.0, max_blur_strength, second_blink_duration)

	# Augen geschlossen halten
	await get_tree().create_timer(eyes_closed_hold).timeout

	# Szene wechseln
	GlobalScript.change_scene(next_scene_path)

	# Aufwachen: Augen öffnen + Blur weg
	await animate_shader("blink_progress", 1.0, 0.0, second_blink_duration * 2)
	await animate_shader("blur_strength", max_blur_strength, 0.0, second_blink_duration)

	visible = false
	
func play_sleep_wake_nosound(next_scene_path: String = "") -> void:
	GlobalScript.transition_scene = true
	visible = true

	# Augen schließen + Blur hoch
	await animate_shader("blink_progress", 0.0, 1.0, second_blink_duration)
	await animate_shader("blur_strength", 0.0, max_blur_strength, second_blink_duration)

	# Augen geschlossen halten
	await get_tree().create_timer(eyes_closed_hold).timeout

	# NUR wenn explizit gewünscht (Legacy / Altcode)
	if next_scene_path != "":
		GlobalScript.change_scene(next_scene_path)

	# Aufwachen
	await animate_shader("blink_progress", 1.0, 0.0, second_blink_duration * 2)
	await animate_shader("blur_strength", max_blur_strength, 0.0, second_blink_duration)

	visible = false
	GlobalScript.transition_scene = false

# ------------------------------------------------------
# Hilfsfunktion: Einzelnes Blinzeln mit Blur gekoppelt
# ------------------------------------------------------
func animate_blink(duration: float) -> void:
	var t := 0.0
	while t < duration:
		var progress = t / duration
		# Augen schließen und wieder öffnen innerhalb der Dauer
		var blink_value = lerp(0.0, 1.0, progress*2) if progress < 0.5 else lerp(1.0, 0.0, (progress-0.5)*2)
		mat.set_shader_parameter("blink_progress", blink_value)
		# Blur während des Blinzelns (optional leicht)
		mat.set_shader_parameter("blur_strength", blink_value * max_blur_strength * 0.5)
		await get_tree().process_frame
		t += get_process_delta_time()
	mat.set_shader_parameter("blink_progress", 0.0)
	mat.set_shader_parameter("blur_strength", 0.0)

# ------------------------------------------------------
# Shaderparameter linear animieren
# ------------------------------------------------------
func animate_shader(param: String, from: float, to: float, duration: float) -> void:
	var t := 0.0
	while t < duration:
		var v = lerp(from, to, t / duration)
		mat.set_shader_parameter(param, v)
		await get_tree().process_frame
		t += get_process_delta_time()
	mat.set_shader_parameter(param, to)

func play_wake_up(next_scene_path: String = "") -> void:
	GlobalScript.transition_scene = true
	visible = true

	# NUR wechseln, wenn explizit gewünscht (z. B. alter Code)
	if next_scene_path != "":
		GlobalScript.change_scene(next_scene_path)

	# Aufwachen: Augen öffnen + Blur weg
	await animate_shader("blink_progress", 1.0, 0.0, second_blink_duration * 2)
	await animate_shader("blur_strength", max_blur_strength, 0.0, second_blink_duration)

	visible = false
	GlobalScript.transition_scene = false
