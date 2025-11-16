extends RealworldScenes


@onready var door_open_player: AudioStreamPlayer = $Door_Exit/DoorOpenPlayer
@onready var classroom_ambiance_player: AudioStreamPlayer = $SFX/ClassroomAmbiancePlayer


func _ready() -> void:
	scene_name = "realworld_classroom_one"
	player_spawn = Vector2(504, 340)        # Standardposition
	previous_scene_spawn = Vector2(568, 362) # Position, wenn aus Hall kommt
	super._ready()  # Basisklasse _ready aufrufen

func _on_door_exit_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		GlobalScript.transition_scene = true
		door_open_player.play()

func _on_door_exit_body_exited(body: Node2D) -> void:
	if body == GlobalScript.player:
		GlobalScript.transition_scene = false

func _process(_delta: float) -> void:
	if GlobalScript.transition_scene:
		GlobalScript.transition_scene = false
		await get_tree().process_frame
		GlobalScript.previous_scene = "realworld_classroom_one"
		GlobalScript.current_scene = "realworld_hall"
		GlobalScript.change_scene("realworld_hall")
