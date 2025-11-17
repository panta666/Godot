extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	# Speichert die aktuelle Szene für continue
	SaveManager.update_current_scene()
	MusicManager.stop_music()
