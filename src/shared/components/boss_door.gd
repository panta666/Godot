extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@export var required_keys := 4
var is_open = false

func open_door():
	is_open = true
	sprite_2d.visible = false
	$CollisionShape2D.queue_free()
	
