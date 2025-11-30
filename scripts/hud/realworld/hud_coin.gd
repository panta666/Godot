extends Control

var coins = 0
@onready var number_of_coins: Label = $NumberOfCoins

func update_coins(value: int):
	coins = value
	number_of_coins.text = "Coins: " + str(value)
