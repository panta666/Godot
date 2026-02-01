extends Area2D

# ----------------------------------------------
# Inspector-Variablen
# ----------------------------------------------
@export_enum("OOP", "MEDG") var room_type := "OOP"

@export var sit_position: Vector2 = Vector2(0, 0)
@export var stand_position: Vector2 = Vector2(0, 0)

# Falls Stuhl im Raum gespiegelt ist
@export var flip_horizontal: bool = false
# Soll der Player beim Hinsetzen flippen?
@export var flip_player_on_sit: bool = false

# ----------------------------------------------
# Nodes
# ----------------------------------------------
@onready var interactable: Area2D = $Interactable
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound: AudioStreamPlayer = $AudioStreamPlayer

# ----------------------------------------------
# READY
# ----------------------------------------------
func _ready() -> void:
	# Interaktion registrieren
	interactable.interact = _on_interact

	# Stuhl spiegeln (z.B. in MEDG-Raum)
	animated_sprite_2d.flip_h = flip_horizontal
	
	# Chair nur aktivieren, wenn er nicht gesperrt ist
	interactable.is_interactable = SaveManager.is_chair_unlocked()
	update_interact_text()

	# Signal anhören, falls Chair später freigeschaltet wird
	SaveManager.connect("chair_unlocked_signal", Callable(self, "_on_chair_unlocked"))

# ----------------------------------------------
# PROCESS – UI Text
# ----------------------------------------------
func _process(_delta: float) -> void:
	var player = GlobalScript.player
	if player and interactable.is_interactable:
		if not player.sitting:
			interactable.interact_name = "to sit"
		else:
			interactable.interact_name = "to stand up"

func update_interact_text() -> void:
	if interactable.is_interactable:
		interactable.interact_name = "to sit"
	else:
		interactable.interact_name = ""
		
# ----------------------------------------------
# INTERACTION
# ----------------------------------------------
func _on_interact() -> void:
	if not SaveManager.is_chair_unlocked():
		return # Chair gesperrt

	var player = GlobalScript.player
	if not player:
		return

	var classroom = get_tree().current_scene
	if not classroom.has_node("LevelUI"):
		return
	var level_ui = classroom.get_node("LevelUI") as CanvasLayer
	level_ui.current_room = room_type
	level_ui.update_level_button()

	sound.play()

	# SITZEN
	if not player.sitting:
		player.sit_on_chair(sit_position)
		_set_player_flip(flip_player_on_sit)
		player.is_busy = true
		interactable.is_interactable = true
		level_ui.show_phone_off()
	else:
		# AUFSTEHEN
		player.stand_up(stand_position)
		_set_player_flip(false)
		player.is_busy = false
		interactable.is_interactable = true
		level_ui.hide_phone()

# ----------------------------------------------
# Hilfsfunktion: Player Flip Steuerung
# ----------------------------------------------
func _set_player_flip(do_flip: bool):
	var player = GlobalScript.player
	if not player:
		return

	if not player.has_node("AnimatedSprite2D"):
		return

	var anim := player.get_node("AnimatedSprite2D") as AnimatedSprite2D
	anim.flip_h = do_flip
	
# ----------------------------------------------
# Chair Unlock Signal
# ----------------------------------------------
func _on_chair_unlocked() -> void:
	interactable.is_interactable = true
	update_interact_text()
	print("Chair wieder aktiviert!")
