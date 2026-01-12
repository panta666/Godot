extends Control

var keys = 0
var scene = ""
var drop_manager

@onready var key_label: Label = $KeyLabel


func _ready() -> void:
	drop_manager = find_parent("Player_Dreamworld").get_parent().find_child("Drop_Manager")
	print(drop_manager.keys)
	drop_manager.key_collected.connect(update_keys)


#Aktualisiert das UI zur Anzeige der Keys
#value: Gesamte Anzahl der Keys
func update_keys(value: int):
	keys = value
	key_label.text = "Keys: " + str(value) + "/4"

#func set_scene(scene_name: String):
#	var loaded_coins = SaveManager.get_ammount_dreamworld_coins(scene_name)
#	update_coins(scene_name, loaded_coins)
