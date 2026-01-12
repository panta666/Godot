extends Area2D

#@onready var player_dreamworld: CharacterBody2D = %Player_Dreamworld
#@onready var player_dreamworld_tutorial: CharacterBody2D = %Player_Dreamworld

var drop_manager

#Beim Einsammeln wird die Anzahl der Keys im drop_manager erhöht und der key verschwindet
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		drop_manager = body.get_parent().find_child("Drop_Manager")
		drop_manager.add_key()
		queue_free()
