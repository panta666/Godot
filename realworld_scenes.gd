extends Node2D
class_name RealworldScenes

var level_ui: CanvasLayer
var player_spawn: Vector2 = Vector2.ZERO
var previous_scene_spawn: Vector2 = Vector2.ZERO
var scene_name: String = ""

func _ready() -> void:
	MusicManager.playMusic(MusicManager.MusicType.HUB)
	SaveManager.update_current_scene(get_tree().current_scene.scene_file_path)

	_init_player()
	_load_ui()

	# --- Fade-In starten, wenn die vorherige Tür einen Fade-Out ausgelöst hat ---
	if GlobalScript.last_door_for_transition and is_instance_valid(GlobalScript.last_door_for_transition):
		var door_node = GlobalScript.last_door_for_transition
		GlobalScript.last_door_for_transition = null  # Reset, damit nicht nochmal abgespielt wird
		await door_node._fade_in(2.0)

func _init_player() -> void:
	# Spieler laden oder übernehmen
	if not GlobalScript.player or not is_instance_valid(GlobalScript.player):
		var player_scene = load("res://scenes/player_realworld.tscn")
		GlobalScript.player = player_scene.instantiate()
		add_child(GlobalScript.player)
	elif GlobalScript.player.get_parent() != self:
		GlobalScript.player.get_parent().remove_child(GlobalScript.player)
		add_child(GlobalScript.player)

	# Spielerposition setzen
	if GlobalScript.previous_scene == "realworld_hall":
		GlobalScript.player.global_position = previous_scene_spawn
	else:
		GlobalScript.player.global_position = player_spawn

	GlobalScript.player.visible = true
	GlobalScript.player.can_move = true

	# --- Animation absichern (Godot 4-kompatibel) ---
	if GlobalScript.player.has_node("AnimatedSprite2D"):
		var anim_sprite: AnimatedSprite2D = GlobalScript.player.get_node("AnimatedSprite2D")
		var anim_name = "idle_%s" % GlobalScript.player.facing_direction

		if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation(anim_name):
			anim_sprite.play(anim_name)
		else:
			# Fallback, falls Animation nicht existiert
			if anim_sprite.sprite_frames:
				var all_anims = anim_sprite.sprite_frames.get_animation_names()
				if all_anims.size() > 0:
					print("Keine '%s'-Animation gefunden, spiele '%s'." % [anim_name, all_anims[0]])
					anim_sprite.play(all_anims[0])
				else:
					print("Kein Animationseintrag in SpriteFrames vorhanden.")
			else:
				print("AnimatedSprite2D hat keine SpriteFrames-Ressource!")

func _load_ui() -> void:
	if not level_ui:
		var ui_scene = load("res://scenes/level_ui.tscn")
		level_ui = ui_scene.instantiate()
		add_child(level_ui)
	elif not level_ui.is_inside_tree():
		add_child(level_ui)
	level_ui.hide_enter_button()
