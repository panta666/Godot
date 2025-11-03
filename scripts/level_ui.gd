extends CanvasLayer
# level_ui ist dafür da, dass man in die Dreamworld (Plattformer) wechseln kann
@onready var enter_level_button: Button = $Control/EnterLevelButton

func _ready():
	enter_level_button.visible = false
	enter_level_button.connect("pressed", Callable(self, "_on_enter_button_pressed"))

func show_enter_button():
	enter_level_button.visible = true

func hide_enter_button():
	enter_level_button.visible = false

func _on_enter_button_pressed():
	MusicManager.playMusic(MusicManager.MusicType.NONE)
	print("Level betreten!")
	get_tree().change_scene_to_file("res://scenes/level/level_one.tscn") # Platzhalter
