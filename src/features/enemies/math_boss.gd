extends "res://src/features/enemies/generic_enemy.gd"

@export var boss_trigger: Boss_Trigger

var bar_instance
var boss_bar = preload("res://src/features/enemies/math_boss_healthbar.tscn")
var invincible := true
var exhausted := false

var attack_counter := 0

var MAX_ATTACK = 10

@onready var health = $Health

@export var boss_of_level = ""

func _ready() -> void:
	health.immortality = true
	
func _spawn_healthbar() -> void:
	print("spawned healthbar")
	bar_instance = boss_bar.instantiate()
	get_tree().current_scene.add_child(bar_instance)
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
	
func _exhaust() -> void:
	exhausted = true
	_play_animation_scaled("fall", 0.5)
	await get_tree().create_timer(0.5).timeout
	sprite.play("exhausted")
	invincible = false
	health.immortality = false
	await get_tree().create_timer(8).timeout
	invincible = false
	health.immortality = false
	exhausted = false
	
func _end_attack() -> void:
		is_attacking = false
		is_walking = true
		attack_allowed = true
		sprite.play("walk")
		attack_counter += 1
		if attack_counter >= MAX_ATTACK:
			_exhaust()
	
	
func _on_hurt_box_received_damage(damage: int, _attacker_pos: Vector2) -> void:
	if not invincible:
		if bar_instance != null:
			bar_instance.update()
		flash_anim.play("flash")
		damaged.emit(damage)
		GlobalScript.enemy_damaged.emit(damage)
		_stun()
	
func _handle_player_logic() -> void:
	if not exhausted:
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
		
func _on_health_depleted() -> void:
	die()
		
func die() -> void:
	bar_instance._deplete()

	queue_free()


func _return_to_classroom() -> void:
	GlobalScript.save_coins_for_level(boss_of_level)

	await get_tree().create_timer(0.2).timeout

	# Blink Overlay laden
	var blink_overlay = preload("res://src/shared/components/blink_overlay.tscn").instantiate()
	get_tree().root.add_child(blink_overlay)
	
	var overlay = blink_overlay.get_node("Blink_Overlay")
	# Transition zurück in die echte Welt
	await overlay.play_wake_up()
	GlobalScript.change_scene("realworld_classroom_two")
	
