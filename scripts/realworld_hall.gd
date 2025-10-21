extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	changeScene()


func _on_classroom_one_door_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = true

func _on_classroom_one_door_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = false
		
func changeScene():
	if global.transition_scene == true:
		if global.current_scene == 'realworld_hall':
			get_tree().change_scene_to_file("res://scenes/realworld_classroom_one.tscn")
			global.finish_change_scene()
			
	
