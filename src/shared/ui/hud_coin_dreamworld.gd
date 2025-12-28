extends Control
var coins = 0
var scene = ""

@onready var coin_label: Label = $CoinLabel


func _ready() -> void:
	GlobalScript.coin_collected.connect(update_coins)

func update_coins(_level_name:String, value: int):
	coins = value
	coin_label.text = "Coins: " + str(value) + "/5"

func set_scene(scene_name: String):
	var loaded_coins = SaveManager.get_ammount_dreamworld_coins(scene_name)
	update_coins(scene_name, loaded_coins)
