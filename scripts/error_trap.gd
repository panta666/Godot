extends Node2D

@export var speed = 160.0
var current_speed = 0.0
#@onready var trap = get_node("Node/Label")

func _physics_process(delta: float) -> void:
	position.y += current_speed * delta

func _on_hitbox_area_entered(_area: Area2D) -> void:
	get_tree().reload_current_scene()
	#print("its a trap")


func _on_player_detect_area_entered(_area: Area2D) -> void:
	#print("detected")
	#await get_tree().create_timer(2).timeout
	$Label.visible = true
	fall()

func fall():
	current_speed = speed
	await get_tree().create_timer(5).timeout
	queue_free()
