extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	self.visible = GlobalScript.tutorial_on


func set_blinking_on(state: bool, speed := 0):
	sprite_2d.material.set_shader_parameter('blink_toggle', state)
	if (speed > 0):
		sprite_2d.material.set_shader_parameter('blink_speed', speed)
