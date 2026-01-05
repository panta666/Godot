extends Node

@export var items := [
	preload("res://scenes/key.tscn"),
	preload("res://scenes/key.tscn"),
	preload("res://scenes/key.tscn"),
	preload("res://scenes/key.tscn")
]

var keys = 0
var enemies: Array[Enemy] = []
var door

func _ready() -> void:
	distribute_items()
	
func distribute_items():
	for e in get_tree().get_nodes_in_group("enemy"):
		if e is Enemy:
			enemies.append(e)
	enemies.shuffle()
	
	for i in range(items.size()):
		enemies[i].give_item(items[i])

func add_key():
	keys += 1
	print(keys)
	if keys == 4:
		print("open")
		door = get_parent().find_child("Boss_door")
		door.open_door()
		
