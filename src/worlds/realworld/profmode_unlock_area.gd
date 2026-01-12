extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body != GlobalScript.player:
		return
	print("I feel like a PROf")
	GlobalScript.set_prof_mode(not GlobalScript.is_prof_mode())
