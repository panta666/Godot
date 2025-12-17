extends CanvasLayer

@export var next_scene : String
@export var skip_key := "K"

func _ready() -> void:
	# Optional: UI Text automatisch aktualisieren
	if has_node("Label"):
		$"Label".text = "%s to Skip" % skip_key

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("skip"):
		_skip()

func _skip() -> void:
	# Zielszene setzen & wechseln
	GlobalScript.current_scene = "train_scene"
	GlobalScript.change_scene("realworld_hall")
