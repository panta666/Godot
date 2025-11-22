extends CenterContainer

@onready var tutorial_check_box: CheckBox = $VBoxContainer/TutorialCheckBox


func _ready() -> void:
	tutorial_check_box.button_pressed = GlobalScript.tutorial_on

func _on_tutorial_check_box_toggled(toggled_on: bool) -> void:
	GlobalScript.set_tutorial_enabled(toggled_on)
