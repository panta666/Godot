extends Node

signal key_collected(total_keys: int)

@export var items := [
	preload("res://src/shared/components/key.tscn"),
	preload("res://src/shared/components/key.tscn"),
	preload("res://src/shared/components/key.tscn"),
	preload("res://src/shared/components/key.tscn")
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
	key_collected.emit(keys)
	if keys == 4:
		print("open")
		door = get_parent().find_child("Boss_door")
		door.open_door()
		
func get_key_status() -> int:
	return keys
