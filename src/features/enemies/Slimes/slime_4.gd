extends "res://src/features/enemies/generic_enemy.gd"
class_name Slime_4

var slime_scene := preload("res://src/features/enemies/Slimes/slime_2.tscn")

var slime_offset = Vector2(40, -5)
var slime_offset2 = Vector2(-40, -5)
var slime_scale = 1

func _on_health_depleted() -> void:
	healthbar._deplete()
	var slime = slime_scene.instantiate()
	var slime2 = slime_scene.instantiate()
	get_tree().root.add_child(slime)
	get_tree().root.add_child(slime2)
	
	slime.collision_layer = 4
	slime2.collision_layer = 4
	
	slime.position = global_position + slime_offset
	slime2.position = global_position + slime_offset2
	
	slime.scale = Vector2(slime_scale, slime_scale)
	slime2.scale = Vector2(slime_scale, slime_scale)
	
	queue_free()
