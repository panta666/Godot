extends CanvasLayer

@export_file("*.tscn") var next_scene : String
@export var skip_key := "K"

func _ready() -> void:
	# Optional: UI Text automatisch aktualisieren
	if has_node("Label"):
		$"Label".text = "%s to Skip" % skip_key

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("skip"):
		_skip()

func _skip() -> void:
	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)
	else:
		push_warning("No next_scene set on skip_scene!")
