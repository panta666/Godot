extends RealworldScenes

func _ready() -> void:
	scene_name = "realworld_classroom_two"
	previous_scene_spawn = Vector2(1135, 710) # Wenn aus Hall kommt
	super._ready()

func _on_door_exit_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		GlobalScript.transition_scene = true

func _on_door_exit_body_exited(body: Node2D) -> void:
	if body == GlobalScript.player:
		GlobalScript.transition_scene = false

func _process(_delta: float) -> void:
	if GlobalScript.transition_scene:
		GlobalScript.transition_scene = false
		await get_tree().process_frame
		GlobalScript.previous_scene = "realworld_classroom_two"
		GlobalScript.current_scene = "realworld_hall"
		GlobalScript.change_scene("realworld_hall")
