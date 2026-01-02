extends "res://src/features/enemies/generic_enemy.gd"
class_name OOP_Boss

@export var boss_of_level = ""

@export var boss_trigger: Boss_Trigger

func _ready() -> void:
	call_deferred("_spawn_healthbar")

func _get_visible_player() -> CharacterBody2D:
	return boss_trigger._get_player()
	
func _handle_player_logic() -> void:
	if _detect_player():
		is_walking = true
		sprite.play("walk")
		_start_attack()
		if not is_dashing:
			_track_player()
	else:
		player = null
		is_walking = true
		sprite.play("walk")
		sound_player.play_sound(Enemysound.soundtype.WALK)

func _on_health_depleted() -> void:
	healthbar._deplete()
	print("Level One Bereich betreten! OOP Level 2 freischalten.")

	# Level 2 für OOP freischalten
	GlobalScript.unlock_level(GlobalScript.classrooms.oop, 2)
	#Shop freischalten in Realworld
	SaveManager.unlock_shop()
	
	# TEST MATH Room freischalten
#----------------------------------------------------------------
	# BITTE ENTFERNEN UND IN BOSS FÜR LEVEL 2 HINZUFÜGEN
	SaveManager.unlock_door("realworld_math_door")
#----------------------------------------------------------------

	# LevelUI aktualisieren, falls vorhanden
	var classroom = get_tree().current_scene
	if classroom.has_node("LevelUI"):
		var level_ui = classroom.get_node("LevelUI") as CanvasLayer
		# level_ui muss die unlock Funktion oder update_level_button nutzen
		if "unlock_oop_level" in level_ui:
			level_ui.unlock_oop_level(1)
		else:
			level_ui.update_level_button()
			
	await _return_to_classroom()
	queue_free()


func _return_to_classroom() -> void:
	GlobalScript.save_coins_for_level(boss_of_level)
	# Kurze Wartezeit
	await get_tree().create_timer(0.2).timeout
	print("change scene")
	# Szenenwechsel zurück
	GlobalScript.change_scene("realworld_classroom_one")

func _on_hurt_box_received_damage(_damage: int, attacker_pos: Vector2) -> void:
	healthbar.update()
	flash_anim.play("flash")


func _on_hurt_box_torso_received_damage(damage: int, attacker_position: Vector2) -> void:
	healthbar.update()
	flash_anim.play("flash")


func _on_hurt_box_legs_received_damage(damage: int, attacker_position: Vector2) -> void:
	healthbar.update()
	flash_anim.play("flash")
