extends Control

var coins = 0
@onready var number_of_coins_label: Label = $"."

func _ready() -> void:
	GlobalScript.realworld_coins_update.connect(update_coins)

func update_coins(value: int):
	coins = value
	number_of_coins_label.text = "Coins: " + str(value)
