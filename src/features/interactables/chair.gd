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


# ----------------------------------------------
# INTERACTION
# ----------------------------------------------
func _on_interact() -> void:
	var player = GlobalScript.player
	if not player:
		return

	# LevelUI suchen
	var classroom = get_tree().current_scene
	if not classroom.has_node("LevelUI"):
		return

	var level_ui = classroom.get_node("LevelUI") as CanvasLayer

	# ------------------------------------------
	# LevelUI korrekt auf Raum setzen (OOP/MEDG)
	# ------------------------------------------
	level_ui.current_room = room_type
	level_ui.update_level_button()

	sound.play()

	# ------------------------------------------
	# SITZEN
	# ------------------------------------------
	if not player.sitting:

		player.sit_on_chair(sit_position)

		# Player flippen wenn gewünscht
		_set_player_flip(flip_player_on_sit)

		player.is_busy = true
		interactable.is_interactable = true

		# Phone screen erscheint (ausgeschaltet)
		level_ui.show_phone_off()

	# ------------------------------------------
	# AUFSTEHEN
	# ------------------------------------------
	else:
		player.stand_up(stand_position)

		# Flip zurücksetzen
		_set_player_flip(false)

		player.is_busy = false
		interactable.is_interactable = true

		# Handy komplett schließen
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
