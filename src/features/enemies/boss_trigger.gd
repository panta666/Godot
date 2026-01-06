extends Area2D

class_name Boss_Trigger

var player

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if player == null:
			player = body
		else:
			player = null
			
func _get_player() -> Node2D:
	return player
