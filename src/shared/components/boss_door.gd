extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
var is_open = false

#Öffnet die Tür bei aktiviertem Bossmode
func _ready():
	if GlobalScript.is_prof_mode():
		open_door()

#Öffnet die Tür zum Bossraum
func open_door():
	is_open = true
	sprite_2d.visible = false
	$CollisionShape2D.queue_free()
	
