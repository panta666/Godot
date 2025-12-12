extends CanvasLayer

var shop: Shop
var current_item := 0
var select = 0

@onready var item_icon: AnimatedSprite2D = $Control/AnimatedSprite2D
@onready var item_name_label: Label = $Control/Name
@onready var item_desc_label: Label = $Control/Desc


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if shop and shop.shop_items.size() > 0:
		show_item(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func open_shop_ui():
	if shop and shop.shop_items.size() > 0:
		show_item(0)
	show() # UI sichtbar machen

# Anzeige eines Items
func show_item(index: int) -> void:
	if shop.shop_items.size() == 0:
		return
	current_item = index % shop.shop_items.size()
	var data: ShopData = shop.shop_items[current_item]

	# AnimatedSprite2D Icon setzen
	item_icon.sprite_frames = data.sprite_frames
	item_icon.animation = "default"
	item_icon.play()

	# Name & Beschreibung
	item_name_label.text = data.item_name
	item_desc_label.text = data.description

func _on_prev_pressed() -> void:
	show_item((current_item - 1 + shop.shop_items.size()) % shop.shop_items.size())


func _on_next_pressed() -> void:
	show_item((current_item + 1) % shop.shop_items.size())


func _on_buy_pressed() -> void:
	if not shop or shop.shop_items.size() == 0:
		return

	var data: ShopData = shop.shop_items[current_item]

	# Upgrade merken
	var key = data.powerup_name

	if key in SaveManager.save_data["player_stats"]:
		SaveManager.save_data["player_stats"][key] = true
		SaveManager.save_game()
		print("Upgrade gespeichert:", key)
	else:
		print("Fehler: Upgrade existiert nicht im SaveManager:", key)
