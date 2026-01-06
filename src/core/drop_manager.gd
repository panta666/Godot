extends Node

@export var items := [
	preload("res://scenes/coin.tscn"),
	preload("res://scenes/coin.tscn")
]

var enemies: Array[Enemy] = []

func _ready() -> void:
	distribute_items()
	
func distribute_items():
	#var enemies = get_tree().get_nodes_in_group("enemy")
	for e in get_tree().get_nodes_in_group("enemy"):
		if e is Enemy:
			enemies.append(e)
	enemies.shuffle()
	
	for i in range(items.size()):
		#enemies[i].get_parent().give_item(items[i])
		enemies[i].give_item(items[i])
