extends Node

signal key_collected(total_keys: int)

#dropbare Items, die an die Gegner verteilt werden
@export var items := [
	preload("res://src/shared/components/key.tscn"),
	preload("res://src/shared/components/key.tscn"),
	preload("res://src/shared/components/key.tscn"),
	preload("res://src/shared/components/key.tscn")
]
#Anzahl der gesammelten Schlüssel
var keys = 0

#Liste aller Gegner im Level
var enemies: Array[Enemy] = []

#Node der Tür zum Bossraum
var door

func _ready() -> void:
	distribute_items()
	
#Alle Gegner werden einem Array hinzugefügt und dann zufällig gemischt.
#Danach werden alle items verteiilt
func distribute_items():
	for e in get_tree().get_nodes_in_group("enemy"):
		if e is Enemy:
			enemies.append(e)
	enemies.shuffle()
	
	for i in range(items.size()):
		enemies[i].give_item(items[i])

#Die Anzahl der Keys wird erhöht.
#Wenn genug Keys vorhanden sind wird die Tür zum Bossraum geöffnet
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
