extends Label
var coins = 0


func _ready() -> void:
	GlobalScript.coin_collected.connect(update_coins)

func update_coins(level_name:String, value: int):
	print("update coins: " + str(value))
	coins = value
	text = "Coins: " + str(value)
