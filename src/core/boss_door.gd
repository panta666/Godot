extends StaticBody2D

@export var required_keys := 4
var is_open = false

func open_door():
	is_open = true
	$CollisionShape2D.queue_free()
	
