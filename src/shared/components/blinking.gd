extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

# Auswahl der möglichen Texturen.
@export_enum("Kreis", "Pfeil") var chosen_type = 0
var possible_types = ["res://assets/VFX/orange_circle.png","res://assets/VFX/arrow.png"]


func _ready() -> void:
	enable_tutorial(GlobalScript.tutorial_on)
	# Wir verbinden das Signal aus dem GlobalScript mit unserer Funktion.
	GlobalScript.tutorial_toggled.connect(set_blinking_on)
	
	# Lade die ausgewählte Texture. Default ist Kreis.
	var current_trxture = load(possible_types[chosen_type])
	sprite_2d.texture = current_trxture


func set_blinking_on(state: bool, speed := 0):
	sprite_2d.material.set_shader_parameter('blink_toggle', state)
	if (speed > 0):
		sprite_2d.material.set_shader_parameter('blink_speed', speed)

func set_blinking_speed(speed: float):
	sprite_2d.material.set_shader_parameter('blink_speed', speed)

func enable_tutorial(enable: bool = true):
	set_blinking_on(enable)
