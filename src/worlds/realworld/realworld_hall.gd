extends RealworldScenes

var next_scene_from_door: String = ""
const PLAYER_SPAWN_POS_ONE := Vector2(184, 420)
const PLAYER_SPAWN_POS_TWO := Vector2(280, 420)
const PLAYER_SPAWN_POS_HOME := Vector2(434, 1190)
@onready var door_closed_player: AudioStreamPlayer = $SFX/DoorClosedPlayer
@onready var classroom_ambiance_player: AudioStreamPlayer = $SFX/ClassroomAmbiancePlayer



func _ready() -> void:
	# Speichert die aktuelle Szene für continue
	SaveManager.update_current_scene()
	# --- Player sicher in die aktuelle Szene verschieben oder neu spawnen ---
	GlobalScript.move_player_to_current_scene()

	# Starte Hintergrundgeräusche
	classroom_ambiance_player.play()
	scene_name = "realworld_hall"
	player_spawn = Vector2(567, 416) # Standardposition
	previous_scene_spawn = Vector2.ZERO
	super._ready()
	Dialogic.signal_event.connect(_on_dialogic_signal)

	# Player direkt an Tür setzen
	if GlobalScript.previous_scene == "realworld_classroom_one":
		GlobalScript.player.global_position = PLAYER_SPAWN_POS_ONE
	elif GlobalScript.previous_scene == "realworld_classroom_two":
		GlobalScript.player.global_position = PLAYER_SPAWN_POS_TWO
	elif GlobalScript.previous_scene == "train_scene":
		GlobalScript.player.global_position = PLAYER_SPAWN_POS_HOME
	else:
		GlobalScript.player.global_position = PLAYER_SPAWN_POS_ONE

func _on_classroom_three_door_3_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		door_closed_player.play()

func _on_door_closed_9_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		door_closed_player.play()


func _on_door_closed_8_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		door_closed_player.play()


func _on_door_closed_7_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		door_closed_player.play()


func _on_door_closed_6_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		door_closed_player.play()


func _on_door_closed_5_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		door_closed_player.play()


func _on_door_closed_4_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		door_closed_player.play()


func _on_door_closed_3_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		door_closed_player.play()


func _on_door_closed_2_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		door_closed_player.play()


func _on_door_closed_body_entered(body: Node2D) -> void:
	if body == GlobalScript.player:
		door_closed_player.play()


func _on_dialogic_signal(event_name: String) -> void:
	var player = GlobalScript.player
	if not player:
		return

	# --- Cutscene Ende ---
	if event_name.begins_with("cutscene_end"):
		if player.has_method("cutscene_end"):
			player.cutscene_end()
			print("Cutscene beendet, Spieler freigegeben!")
