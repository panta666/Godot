extends Control

const COLOR_FULL_LIFE: Color = Color.BLUE
const COLOR_LOW_LIFE: Color = Color.RED
const TEXT_COLOR: Color = Color.WHITE
const BORDER_COLOR: Color = Color(0.2, 0.2, 0.2)
const SPEED: float = 2.0
const BORDER_THICKNESS: float = 2.0
const FONT_SIZE: int = 14

var base_amplitude: float = 5.0
var base_frequency: float = 2.0
var amplitude_factor: float = 20.0

var time: float = 0.0
var health_component: Health

func set_health_component(health: Health):
	health_component = health
	health.health_changed.connect(_on_health_changed)
	health.max_health_changed.connect(_on_health_changed)
	health.health_depleted.connect(_on_health_changed)

func _on_health_changed(_diff: int = 0):
	queue_redraw()

func _process(delta: float) -> void:
	#Geschwindigkeit der Kurve berechnen
	if health_component != null:
		var health_ratio = float(health_component.get_health()) / float(health_component.get_max_health())
		var dynamic_speed = SPEED + (1.0 - health_ratio) * 6.0
		time += delta * dynamic_speed
	else:
		time += delta * SPEED
	
	queue_redraw()

func _draw() -> void:
	if health_component == null:
		return
	
	#HP-Werte Holen
	var health = health_component.get_health()
	var max_health = health_component.get_max_health()
	var health_ratio = float(health) / float(max_health)

	#Werte für die Sinus kurve berechnen
	var amplitude = base_amplitude + (1.0 - health_ratio) * amplitude_factor
	var frequency = base_frequency + (1.0 - health_ratio) * 5.0
	var wave_color = COLOR_FULL_LIFE.lerp(COLOR_LOW_LIFE, 1.0 - health_ratio)

	var width = size.x
	var height = size.y / 2.0

	# Rahmen zeichnen
	var rect = Rect2(Vector2(0, 0), size)
	draw_rect(rect, BORDER_COLOR, false, BORDER_THICKNESS)

	# Sinuskurve zeichnen
	var points = PackedVector2Array()
	for x in range(int(width)):
		var y = height + sin((x / width) * TAU * frequency + time) * amplitude
		points.append(Vector2(x, y))
	draw_polyline(points, wave_color, 2.0)

	# HP anzeigen
	var display_text = str(health, " / ", max_health)
	var font := get_theme_default_font()
	var text_size := font.get_string_size(display_text)
	var text_position = Vector2(
		(width - text_size.x) / 2.0,
		size.y - text_size.y / 4.0
	)
	draw_string(font, text_position, display_text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, TEXT_COLOR)
