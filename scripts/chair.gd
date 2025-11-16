extends Area2D

@onready var interactable: Area2D = $Interactable
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var sound: AudioStreamPlayer = $AudioStreamPlayer

# Position, wo der Charakter "teleportiert" wird, wenn er sitzt
@export var sit_position: Vector2 = Vector2(102, 125)
# Position, wo der Charakter nach dem Aufstehen hingestellt wird
@export var stand_position: Vector2 = Vector2(94, 120)

func _ready() -> void:
	interactable.interact = _on_interact

# ------------------------------------------------------
# KOMMENTAR ERINNERUNG FÜR SOUND
# Handy Sound (aus der Tasche ziehen oder sowas) (benötigen wir auch wenn wir ESC später drücken fürs "Inventar", "Menu" etc.
# ------------------------------------------------------

func _process(_delta: float) -> void:
	var player = GlobalScript.player
	if player and interactable.is_interactable:
		if not player.sitting:
			interactable.interact_name = "Press F to sit"
		else:
			interactable.interact_name = "Press F to stand up"

func _on_interact() -> void:
	var player = GlobalScript.player
	if not player:
		return

	var classroom = get_tree().current_scene
	if not classroom.has_node("LevelUI"):
		return

	var level_ui = classroom.get_node("LevelUI") as CanvasLayer
	sound.play()
	if not player.sitting:
		# Auf den Stuhl setzen
		player.sit_on_chair(sit_position)
		player.is_busy = true
		interactable.is_interactable = true
		# Zeige Phone_Off, PowerArea wird aktiv
		level_ui.show_phone_off()
	else:
		# Aufstehen
		player.stand_up(stand_position)
		player.is_busy = false
		interactable.is_interactable = true
		# Phone komplett ausblenden, egal in welchem Zustand
		level_ui.hide_phone()
