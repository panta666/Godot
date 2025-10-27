extends CharacterBody2D

@export var npc_data: NPCData
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interactable: Area2D = $Interactable
@onready var label: Label = $NameLabel

func _ready() -> void:
	if npc_data == null:
		push_error("Fehler: Kein NPCData für " + name)
		return

	# Aussehen & Name setzen
	animated_sprite.sprite_frames = npc_data.sprite_frames
	label.text = npc_data.npc_name
	label.visible = false

	# Start-Ausrichtung
	_set_facing(npc_data.start_facing)

	# Interaktion vorbereiten
	interactable.interact_name = npc_data.npc_name
	interactable.interact = _on_interact
	interactable.connect("body_entered", _on_body_entered)
	interactable.connect("body_exited", _on_body_exited)

	# Standardanimation
	match npc_data.start_facing:
		"up":
			animated_sprite.play(npc_data.idle_up)
		"side":
			animated_sprite.play(npc_data.idle_side)
		_:
			animated_sprite.play(npc_data.idle_down)


func _set_facing(dir: String) -> void:
	match dir:
		"left":
			animated_sprite.flip_h = true
			animated_sprite.play(npc_data.idle_side)
		"right":
			animated_sprite.flip_h = false
			animated_sprite.play(npc_data.idle_side)
		"up":
			animated_sprite.play(npc_data.idle_up)
		_:
			animated_sprite.play(npc_data.idle_down)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		label.visible = false

func _on_interact() -> void:
	if npc_data.can_talk:
		print("Starte Dialog mit ", npc_data.npc_name)
		# Hier später: Dialogic.start("dialog_" + npc_data.npc_name)
	else:
		print(npc_data.npc_name, " reagiert nicht.")
