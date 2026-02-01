extends Node

signal key_collected(total_keys: int)

#Anzahl der gesammelten Schlüssel
var keys = 0

#Szene des Schlüssels
@export var key_scene: PackedScene
#Anzahl der verteilten Keys
@export var key_count := 4

#Liste aller Gegner im Level
var enemies: Array[Enemy] = []

#Node der Tür zum Bossraum
var door

func _ready() -> void:
	distribute_items()
	
#Alle Gegner werden einem Array hinzugefügt und dann zufällig gemischt.
#Danach werden alle items verteiilt
func distribute_items():
	enemies.clear()
	for e in get_tree().get_nodes_in_group("enemy"):
		if e is Enemy:
			enemies.append(e)
	enemies.shuffle()
	
	var count: int = min(key_count, enemies.size())

	for i in range(count):
		enemies[i].give_item(key_scene)

#Die Anzahl der Keys wird erhöht.
#Wenn genug Keys vorhanden sind wird die Tür zum Bossraum geöffnet
func add_key():
	keys += 1
	print(keys)
	key_collected.emit(keys)
	if keys >= key_count:
		print("open")
		door = get_parent().find_child("Boss_door")
		door.open_door()
		
func get_key_status() -> int:
	return keys
