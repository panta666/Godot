extends "res://src/features/enemies/generic_enemy.gd"

@export var boss_trigger: Boss_Trigger

var bar_instance
var boss_bar = preload("res://src/features/enemies/math_boss_healthbar.tscn")

func _ready() -> void:
	pass
	
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
	
func _on_hurt_box_received_damage(damage: int, _attacker_pos: Vector2) -> void:
	if bar_instance != null:
		bar_instance.update()
	flash_anim.play("flash")
	_apply_knockback(_attacker_pos)
	damaged.emit(damage)
	GlobalScript.enemy_damaged.emit(damage)
	_stun()
	
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
