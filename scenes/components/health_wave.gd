extends Control

@export var wave_color: Color = Color.BLUE
@export var base_amplitude: float = 5.0
@export var base_frequency: float = 2.0
@export var speed: float = 2.0
@export var amplitude_factor: float = 20.0
@export var line_width: float = 2.0

var time: float = 0.0
var health_component: Health

# Verbindung mit Health-System
func set_health_component(health: Health):
	health_component = health
	health.health_changed.connect(_on_health_changed)
	health.max_health_changed.connect(_on_health_changed)
	health.health_depleted.connect(_on_health_changed)

func _on_health_changed(diff: int = 0):
	queue_redraw()

func _process(delta: float) -> void:
	time += delta * speed
	queue_redraw()

func _draw() -> void:
	if health_component == null:
		return
	
	var health_ratio = float(health_component.get_health()) / float(health_component.get_max_health())
	var amplitude = base_amplitude + (1.0 - health_ratio) * amplitude_factor
	var frequency = base_frequency + (1.0 - health_ratio) * 3.0
	var color = wave_color.lerp(Color.RED, 1.0 - health_ratio)

	var width = size.x
	var height_center = size.y / 2.0
	var points = PackedVector2Array()

	# Verschiebung der Phase, damit die Welle "nach rechts scrollt"
	var scroll_offset = time * TAU * 0.5

	for x in range(int(width)):
		var y = height_center + sin((x / width) * TAU * frequency + scroll_offset) * amplitude
		points.append(Vector2(x, y))

	draw_polyline(points, color, line_width)
