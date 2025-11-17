extends RealworldScenes
@onready var classroom_ambiance_player: AudioStreamPlayer = $SFX/ClassroomAmbiancePlayer

func _ready() -> void:
	classroom_ambiance_player.play()
	player_spawn = Vector2(1135, 710)
	scene_name = "realworld_classroom_two"
	previous_scene_spawn = Vector2(1135, 710) # Wenn aus Hall kommt
	super._ready()
