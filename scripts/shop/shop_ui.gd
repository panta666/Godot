extends CanvasLayer

var shop: Shop
var current_item := 0
var pending_purchase_item: ShopData = null
var coin_category: String = "" # oop oder math

# UI-Elemente
@onready var item_icon: AnimatedSprite2D = $Control/ItemIconAnimatedSprite2D
@onready var item_name_label: Label = $Control/Name
@onready var item_desc_label: Label = $Control/Desc
@onready var buy_button: Button = $Control/Buy
@onready var prev_button: Button = $Control/Prev
@onready var next_button: Button = $Control/Next
@onready var confirm_popup: AcceptDialog = $Control/ConfirmPopup
@onready var coins_label: Label = $Control/CoinsLabel

func _ready() -> void:
	if shop:
		update_shop_items()
		if shop.shop_items.size() > 0:
			show_item(0)

# Shop öffnen
func open_shop_ui():
	update_shop_items()
	update_coin_display()
	if shop.shop_items.size() > 0:
		show_item(0)
	else:
		show_item(0)  # Leerer Shop Text anzeigen
	show()  # UI sichtbar machen

# Entfernt bereits gekaufte Items aus der Shop-Liste
func update_shop_items() -> void:
	if shop:
		shop.shop_items = shop.shop_items.filter(func(item: ShopData) -> bool:
			var key = item.powerup_name
			return not SaveManager.save_data["player_stats"].get(key, false)
		)

# Anzeige eines Items oder leerem Shop
func show_item(index: int) -> void:
	if shop.shop_items.size() == 0:
		# Shop leer
		item_name_label.text = "You have purchased everything!"
		item_desc_label.text = "For real..there is nothing more in here. You can close this Shop now..really! - Do it..now..pleeease..close me!"
		item_icon.hide()

		# Buttons ausblenden
		buy_button.hide()
		prev_button.hide()
		next_button.hide()
		return

	# Normales Item anzeigen
	current_item = index % shop.shop_items.size()
	var data: ShopData = shop.shop_items[current_item]

	item_icon.show()
	item_icon.sprite_frames = data.sprite_frames
	item_icon.animation = "default"
	item_icon.play()

	item_name_label.text = data.item_name
	item_desc_label.text = data.description

	# Buttons wieder sichtbar machen
	buy_button.show()
	prev_button.show()
	next_button.show()
	
	var can_afford = get_category_coin_count() >= data.price
	buy_button.disabled = not can_afford

# Navigation
func _on_prev_pressed() -> void:
	if shop.shop_items.size() == 0:
		return
	show_item((current_item - 1 + shop.shop_items.size()) % shop.shop_items.size())

func _on_next_pressed() -> void:
	if shop.shop_items.size() == 0:
		return
	show_item((current_item + 1) % shop.shop_items.size())

# Kauf-Logik
func _on_buy_pressed() -> void:
	if not shop or shop.shop_items.size() == 0:
		return
	
	# Item merken
	pending_purchase_item = shop.shop_items[current_item]

	# Text im Popup setzen
	confirm_popup.dialog_text = "Do you want to buy " + pending_purchase_item.item_name + " for " + str(pending_purchase_item.price) + " coins?"
	
	var price = pending_purchase_item.price
	var current_coins = get_category_coin_count()

	if current_coins < price:
		confirm_popup.dialog_text = "You don't have enough coins."
		confirm_popup.popup_centered()
		pending_purchase_item = null
		return
	
	# Popup anzeigen
	confirm_popup.popup_centered()
	
func _on_confirm_popup_confirmed() -> void:
	if pending_purchase_item == null:
		return
	
	var price = pending_purchase_item.price
	var key = pending_purchase_item.powerup_name
	
	# Coins abziehen
	if not spend_category_coins(price):
		print("Nicht genug Coins")
		pending_purchase_item = null
		return

	if key in SaveManager.save_data["player_stats"] and not SaveManager.save_data["player_stats"][key]:
		# Power-Up kaufen
		SaveManager.save_data["player_stats"][key] = true
		SaveManager.save_game()
		print("Upgrade gespeichert:", key)

		# Aus Shop-Liste entfernen
		var index = shop.shop_items.find(pending_purchase_item)
		if index != -1:
			shop.shop_items.remove_at(index)

		# Nächstes Item anzeigen oder leeren Shop anzeigen
		if shop.shop_items.size() > 0:
			show_item(current_item % shop.shop_items.size())
		else:
			show_item(0)
	else:
		print("Fehler: Upgrade existiert nicht im SaveManager oder schon gekauft:", key)

	# Kauf abgeschlossen
	pending_purchase_item = null
	update_coin_display()

#Coins pro OOP oder MATH zusammenzählen
func get_category_coin_count() -> int:
	var total := 0
	var coins_dict = SaveManager.save_data["game_progress"]["coins"]

	for key in coins_dict.keys():
		if key.begins_with(coin_category + "_"):
			if coins_dict[key] is Array:
				total += coins_dict[key].size()

	return total
	
func update_coin_display() -> void:
	var coins = get_category_coin_count()
	coins_label.text = "Coins: " + str(coins)
	
func spend_category_coins(amount: int) -> bool:
	var coins_dict = SaveManager.save_data["game_progress"]["coins"]
	var remaining := amount

	for key in coins_dict.keys():
		if not key.begins_with(coin_category + "_"):
			continue

		if coins_dict[key] is Array:
			while coins_dict[key].size() > 0 and remaining > 0:
				coins_dict[key].pop_back()
				remaining -= 1

		if remaining <= 0:
			break

	if remaining > 0:
		return false # nicht genug Coins

	SaveManager.save_game()
	return true
