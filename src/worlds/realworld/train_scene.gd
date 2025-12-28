extends RealworldScenes

@onready var animation_player: AnimationPlayer = $Train/AnimationPlayer
@onready var scene_camera: Camera2D = $Train/Camera2D

func _ready() -> void:
	scene_name = "train_scene"
	super._ready()

	# Player während der Zugfahrt verstecken & bewegen deaktivieren
	if GlobalScript.player:
		GlobalScript.player.visible = false
		GlobalScript.player.can_move = false
		if GlobalScript.player.camera_2d:
			GlobalScript.player.camera_2d.enabled = false

	scene_camera.make_current()
	
	# Animation starten
	animation_player.play("drive")

	# Signal-Warten, dann Szenenwechsel
	animation_player.animation_finished.connect(_on_train_animation_finished)


func _on_train_animation_finished(anim_name: String) -> void:
	if anim_name == "drive":
		await _fade_out_transition()

	# Zielszene setzen & wechseln
	GlobalScript.current_scene = "train_scene"
	GlobalScript.change_scene("realworld_hall")
	



func _fade_out_transition():
	if GlobalScript.last_door_for_transition:
		return GlobalScript.last_door_for_transition._fade_in(2.0)
	
