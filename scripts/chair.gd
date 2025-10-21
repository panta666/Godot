extends Area2D

@onready var interactable: Area2D = $Interactable
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: Node2D = $"../Player_Realworld"



# Position, wo der Charakter "teleportiert" wird, wenn er sitzt (auf dem Stuhl)
@export var sit_position: Vector2 = Vector2(102, 125)
# Selbes Spiel nur dass er irgendwo neben dem Stuhl steht. Geht wahrscheinlich deutlich modularer
# Zumal chair.gd für alle Level und alle Stühle eventuell genutzt werden soll um Redundanz zu vermeiden
@export var stand_position: Vector2 = Vector2(94, 120)

func _ready() -> void:
	interactable.interact = _on_interact

func _process(_delta: float) -> void:
	if player and interactable.is_interactable:
		if not player.sitting:
			interactable.interact_name = "Press F to sit"
		else:
			interactable.interact_name = "Press F to stand up"
	
func _on_interact():
	if not player:
		return

	var classroom = get_tree().get_current_scene()
	if not classroom.has_node('LevelUI'):
		return
		
	var level_ui = get_tree().get_current_scene().get_node("LevelUI") as CanvasLayer
	
	if not player.sitting:
		# Auf den Stuhl setzen
		player.sit_on_chair(sit_position)
		# Interactable aktiv lassen, damit F drücken erneut möglich ist
		interactable.is_interactable = true
		level_ui.show_enter_button()
	else:
		# Aufstehen
		player.stand_up(stand_position)
		interactable.is_interactable = true
		level_ui.hide_enter_button()
		
