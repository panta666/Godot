extends "res://src/features/enemies/projectile.gd"

var explosion_scene := preload("res://src/features/enemies/explosion.tscn")

@export var size: Vector2 = Vector2(0.5, 0.5)
@export var duaration: float = 1
@export var damage: float = 10
	
func _on_body_entered(body: Node2D) -> void:
	if exception == null or body != exception:
		var explosion = explosion_scene.instantiate()
		explosion.scale = size
		explosion.duration = duaration
		explosion.damage = damage
		explosion.global_position = global_position
		get_tree().current_scene.add_child(explosion)
		queue_free()
