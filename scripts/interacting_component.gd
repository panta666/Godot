extends Node2D
@onready var interact_ui: Control = $InteractUI
@onready var label_left: Label = $InteractUI/HBoxContainer/LabelLeft
@onready var key_icon: AnimatedSprite2D = $InteractUI/HBoxContainer/AnimatedSprite2D
@onready var label_right: Label = $InteractUI/HBoxContainer/LabelRight



var current_interactions := []
var can_interact := true

func _input(event: InputEvent) -> void:
	# ESC-Menü offen - keine Interaktion erlauben
	var esc_menu = GlobalScript.esc_menu_instance
	if esc_menu and (esc_menu.menu_container.visible or esc_menu.options_container.visible):
		# Menü offen - Interaktion blockieren
		return
		
	if event.is_action_pressed('interact') and can_interact:
		if current_interactions.size() > 0:
			can_interact = false
			interact_ui.hide()
			
			# Interaktion ausführen
			current_interactions[0].interact.call()
			
			# Danach wieder freigeben
			can_interact = true

func _process(_delta: float) -> void:
	var esc_menu = GlobalScript.esc_menu_instance
	# Menü offen → keine Anzeige
	if esc_menu and (esc_menu.menu_container.visible or esc_menu.options_container.visible):
		interact_ui.hide()
		return

	# Interaktionen sortieren und Label anzeigen
	if current_interactions and can_interact:
		current_interactions.sort_custom(_sort_by_nearest)
		if current_interactions[0].is_interactable:
			label_right.text = current_interactions[0].interact_name
			interact_ui.show()
	else:
		interact_ui.hide()
		
func _sort_by_nearest(area1, area2):
	var area1_dist = global_position.distance_to(area1.global_position)
	var area2_dist = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist

func _on_interact_range_area_entered(area: Area2D) -> void:
	current_interactions.push_back(area)

func _on_interact_range_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)
