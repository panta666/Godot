extends Node2D
class_name Shop

@export var shop_items: Array[ShopData] = []

@onready var interactable: Area2D = $Interactable
@onready var shop_ui: CanvasLayer = $ShopUI

var shop_open := false

func _ready() -> void:
	# Interaktion registrieren
	interactable.interact = _on_interact
	interactable.is_interactable = true
	
	#ShopUI referenz
	shop_ui.shop = self


func _process(_delta: float) -> void:
	# UI Text setzen
	if interactable.is_interactable:
		if shop_open:
			interactable.interact_name = ""
		else:
			interactable.interact_name = "to open the shop"


func _on_interact() -> void:
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

# ------------------------------------------
	# Helperfunction für shop_ui
	# ------------------------------------------
func buttonCloseHelper() -> void:
	GlobalScript.player.close_shop()
	interactable.is_interactable = true

	# ShopUI schließt sich
	get_node("ShopUI/AnimationPlayer").play("transition_out")
