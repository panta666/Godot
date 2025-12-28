extends CenterContainer

@onready var tutorial_check_box: CheckBox = $VBoxContainer/TutorialCheckBox
@onready var resolution_button: OptionButton = $VBoxContainer/ResolutionOptionButton


func _ready() -> void:
	tutorial_check_box.button_pressed = GlobalScript.tutorial_on
	add_resolutions()
	update_Resolution_Button_value()

func _on_tutorial_check_box_toggled(toggled_on: bool) -> void:
	GlobalScript.set_tutorial_enabled(toggled_on)

func add_resolutions() -> void:
	for res in GlobalScript.resolutions:
		resolution_button.add_item(res)

func update_Resolution_Button_value():
	# Holt sich die Aktuelle Fenstergröße im Format X-SIZE'x'Y-SIZE
	var window_size_string = str(get_window().size.x, "x",get_window().size.y)
	# Holt sich den index der aktuellen Fenstgröße im Array 
	var resolution_index = GlobalScript.resolutions.keys().find(window_size_string)
	resolution_button.selected = resolution_index
	


func _on_resolution_option_button_item_selected(index: int) -> void:
	var key = resolution_button.get_item_text(index)
	get_window().set_size(GlobalScript.resolutions[key])


func _on_check_box_toggled(toggled_on: bool) -> void:
	if (toggled_on): 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
