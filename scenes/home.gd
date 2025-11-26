extends RealworldScenes

func _ready() -> void:
	player_spawn = Vector2(434, 1118)
	scene_name = "home"
	previous_scene_spawn = Vector2(368, 170) # Wenn aus Hall kommt
	super._ready()
