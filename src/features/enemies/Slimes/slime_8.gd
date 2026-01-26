extends "res://src/features/enemies/generic_enemy.gd"
class_name Slime_8

var slime_scene := preload("res://src/features/enemies/Slimes/slime_4.tscn")

var slime_offset = Vector2(30, -5)
var slime_offset2 = Vector2(-30, -5)
var slime_scale = 1.5

func _on_health_depleted() -> void:
	healthbar._deplete()
	call_deferred("drop_item")
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
	
	
func drop_item():
	if carried_item != null:
		print("drop")
		var item = carried_item.instantiate()
		get_parent().add_child(item)
		item.global_position = global_position
