extends Area2D

var drop_manager


func _on_body_entered(body: Node2D) -> void:
	drop_manager = body.get_parent().find_child("Drop_Manager")
	print(drop_manager)
	drop_manager.add_key()
	queue_free()
