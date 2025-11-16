extends RealworldScenes

var next_scene_from_door: String = ""

const PLAYER_SPAWN_POS_ONE := Vector2(184, 420)
const PLAYER_SPAWN_POS_TWO := Vector2(280, 420)


@onready var door_open_player: AudioStreamPlayer = $SFX/DoorOpenPlayer
@onready var door_closed_player: AudioStreamPlayer = $SFX/DoorClosedPlayer
@onready var classroom_ambiance_player: AudioStreamPlayer = $SFX/ClassroomAmbiancePlayer



func _ready() -> void:
	# Speichert die aktuelle Szene für continue
	SaveManager.update_current_scene(get_tree().current_scene.scene_file_path)
	# --- Player sicher in die aktuelle Szene verschieben oder neu spawnen ---
	GlobalScript.move_player_to_current_scene()

	# Starte Hintergrundgeräusche
	classroom_ambiance_player.play()
	scene_name = "realworld_hall"
	player_spawn = Vector2(567, 416) # Standardposition
	previous_scene_spawn = Vector2.ZERO
	super._ready()

	# Player direkt an Tür setzen
	if GlobalScript.previous_scene == "realworld_classroom_one":
		GlobalScript.player.global_position = PLAYER_SPAWN_POS_ONE
	elif GlobalScript.previous_scene == "realworld_classroom_two":
		GlobalScript.player.global_position = PLAYER_SPAWN_POS_TWO
	else:
		GlobalScript.player.global_position = PLAYER_SPAWN_POS_ONE

func _process(_delta: float) -> void:
	if GlobalScript.transition_scene and next_scene_from_door != "":
		GlobalScript.player_positions["realworld_hall"] = GlobalScript.player.global_position
		GlobalScript.previous_scene = "realworld_hall"
		GlobalScript.current_scene = next_scene_from_door
		GlobalScript.change_scene(next_scene_from_door)
		GlobalScript.transition_scene = false
		next_scene_from_door = ""

# Tür-Kollisionssignale
func _on_classroom_one_door_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		GlobalScript.transition_scene = true
		next_scene_from_door = "realworld_classroom_one"
		door_open_player.play()

func _on_classroom_one_door_body_exited(body: Node2D) -> void:
	if body == GlobalScript.player:
		GlobalScript.transition_scene = false
		next_scene_from_door = ""

func _on_classroom_two_door_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		GlobalScript.transition_scene = true
		next_scene_from_door = "realworld_classroom_two"
		door_open_player.play()

func _on_classroom_two_door_body_exited(body: Node2D) -> void:
	if body == GlobalScript.player:
		GlobalScript.transition_scene = false
		next_scene_from_door = ""

func _on_classroom_three_door_3_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		door_closed_player.play()
