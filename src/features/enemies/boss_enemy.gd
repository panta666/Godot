extends "res://src/features/enemies/generic_enemy.gd"
class_name OOP_Boss

@export var boss_of_level = ""

@export var boss_trigger: Boss_Trigger

var bar_instance

var lifes := 3

var boss_bar = preload("res://src/features/enemies/boss_healthbar.tscn")

func _ready() -> void:
	pass

func _spawn_healthbar() -> void:
	print("spawned healthbar")
	bar_instance = boss_bar.instantiate()
	get_tree().root.add_child(bar_instance)
	bar_instance.setup(self)

func _get_visible_player() -> CharacterBody2D:
	return boss_trigger._get_player()
	
func _detect_player() -> bool:
	var collider := _get_visible_player()
	if collider:
		if bar_instance == null:
			_spawn_healthbar()
		player = collider
		return true
	return false

func _handle_player_logic() -> void:
	if _detect_player():
		is_walking = true
		sprite.play("walk")
		_start_attack()
		if not is_dashing:
			_track_player()
	else:
		if bar_instance != null:
			bar_instance.queue_free()
			bar_instance = null
		player = null
		is_walking = true
		sprite.play("walk")
		sound_player.play_sound(Enemysound.soundtype.WALK)


func die() -> void:
	if lifes <= 0:
		bar_instance._deplete()
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

func _on_hurt_box_received_damage(damage: int, _attacker_pos: Vector2) -> void:
	if bar_instance != null:
		bar_instance.update()
	damaged.emit(damage)
	GlobalScript.enemy_damaged.emit(damage)
	flash_anim.play("flash")


func _on_hurt_box_torso_received_damage(damage: int, attacker_position: Vector2) -> void:
	if bar_instance != null:
		bar_instance.update()
	flash_anim.play("flash")


func _on_hurt_box_legs_received_damage(damage: int, attacker_position: Vector2) -> void:
	if bar_instance != null:
		bar_instance.update()
	flash_anim.play("flash")

func _on_health_depleted() -> void:
	lifes -= 1
	die()

func _on_health_torso_health_depleted() -> void:
	lifes -= 1
	die()


func _on_health_legs_health_depleted() -> void:
	lifes -= 1
	print("lifes: ", lifes)
	die()
