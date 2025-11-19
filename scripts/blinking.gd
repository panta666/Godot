extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D


func blinking(state: bool):
	sprite_2d.material.set_shader_parameter('blink_toggle', state)
