extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	enable_tutorial(GlobalScript.tutorial_on)
	# Wir verbinden das Signal aus dem GlobalScript mit unserer Funktion.
	GlobalScript.tutorial_toggled.connect(set_blinking_on)


func set_blinking_on(state: bool, speed := 0):
	sprite_2d.material.set_shader_parameter('blink_toggle', state)
	if (speed > 0):
		sprite_2d.material.set_shader_parameter('blink_speed', speed)

func set_blinking_speed(speed: float):
	sprite_2d.material.set_shader_parameter('blink_speed', speed)

func enable_tutorial(enable: bool = true):
	set_blinking_on(enable)
