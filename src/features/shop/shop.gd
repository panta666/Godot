extends Node2D
class_name Shop

@export var shop_items: Array[ShopData] = []
@export var coin_category: String = "" # mögliche Werte: "oop", "math"
@onready var interactable: Area2D = $Interactable
@onready var shop_ui: CanvasLayer = $ShopUI

var shop_open := false

func _ready() -> void:
	# Interaktion registrieren
	interactable.interact = _on_interact
	
	#Interaktion nur erlauben, wenn Shop unlocked
	interactable.is_interactable = SaveManager.is_shop_unlocked()
	update_interact_text()
	
	#ShopUI referenz
	shop_ui.shop = self
	
	shop_ui.coin_category = coin_category
	
	# Auf Signal hören, wenn Shop freigeschaltet wird
	SaveManager.connect("shop_unlocked_signal", Callable(self, "_on_shop_unlocked"))


func _process(_delta: float) -> void:
	# UI Text setzen
	if interactable.is_interactable:
		if shop_open:
			interactable.interact_name = "hop"
		else:
			interactable.interact_name = "to open the shop"


func update_interact_text() -> void:
	if interactable.is_interactable:
		interactable.interact_name = "to open the shop"
	else:
		interactable.interact_name = "" # Text komplett ausblenden

func _on_interact() -> void:
	if not SaveManager.is_shop_unlocked():
		return # Shop noch gesperrt
	
	var player = GlobalScript.player
	if not player:
		return
	# ------------------------------------------
	# Shop öffnen
	# ------------------------------------------
	if not player.is_shopping:
		player.open_shop()
		interactable.is_interactable = false

		# ShopUI erscheint
		shop_ui.open_shop_ui()
		get_node("ShopUI/AnimationPlayer").play("transition_in")

	# ------------------------------------------
	# Shop schließen
	# ------------------------------------------
	else:
		player.close_shop()
		interactable.is_interactable = true

		# ShopUI schließt sich
		get_node("ShopUI/AnimationPlayer").play("transition_out")
