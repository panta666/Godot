extends Control
@onready var glasses_tr: TextureRect = $GlassesTR


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalScript.prof_mode_visible_updated.connect(set_profmode_image_visible)

func set_profmode_image_visible(_visible: bool):
	glasses_tr.visible = _visible
