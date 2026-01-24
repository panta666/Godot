extends "res://src/features/enemies/generic_enemy.gd"
class_name OOP_Boss

@export var boss_of_level = ""

@export var boss_trigger: Boss_Trigger

var bar_instance

var head_broken := false

var torso_broken := false

var legs_broken := false

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
	if head_broken and torso_broken and legs_broken:
		bar_instance._deplete()
		print("Level One Bereich betreten! OOP Level 2 freischalten.")

		# Level 2 für OOP freischalten
		GlobalScript.unlock_level(GlobalScript.classrooms.oop, 2)

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

	await get_tree().create_timer(0.2).timeout

	# Blink Overlay laden
	var blink_overlay = preload("res://src/shared/components/blink_overlay.tscn").instantiate()
	get_tree().root.add_child(blink_overlay)
	
	var overlay = blink_overlay.get_node("Blink_Overlay")
	# Transition zurück in die echte Welt
	await overlay.play_sleep_wake_nosound("realworld_classroom_one")

func _on_hurt_box_received_damage(damage: int, _attacker_pos: Vector2) -> void:
	if bar_instance != null:
		bar_instance.update()
	if not head_broken:
		flash_anim.play("flash")
		damaged.emit(damage)
		GlobalScript.enemy_damaged.emit(damage)
		flash_anim.play("flash")


func _on_hurt_box_torso_received_damage(damage: int, attacker_position: Vector2) -> void:
	if bar_instance != null:
		bar_instance.update()
	if not torso_broken:
		flash_anim.play("flash")

func _on_hurt_box_legs_received_damage(damage: int, attacker_position: Vector2) -> void:
	if bar_instance != null:
		bar_instance.update()
	if not legs_broken:
		flash_anim.play("flash")

func _on_health_depleted() -> void:
	head_broken = true
	die()

func _on_health_torso_health_depleted() -> void:
	torso_broken = true
	die()
	

func _on_health_legs_health_depleted() -> void:
	legs_broken = true
	die()
