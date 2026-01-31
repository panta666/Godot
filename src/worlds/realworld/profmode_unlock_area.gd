extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body != GlobalScript.player:
		return
	GlobalScript.toggle_prof_mode()
