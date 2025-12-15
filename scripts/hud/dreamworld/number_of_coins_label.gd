extends Label
var coins = 0

func _ready() -> void:
	GlobalScript.coin_collected.connect(update_coins)

func update_coins(_level_name:String, value: int):
	coins = value
	text = "Coins: " + str(value) + "/5"
