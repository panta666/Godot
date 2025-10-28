extends CharacterBody2D

@export var npc_data: NPCData
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var name_label: Label = $NameLabel
@onready var interactable: Area2D = $Interactable
@onready var interact_range: Area2D = $InteractRange
@onready var player: PlayerRealworld = $"../Player_Realworld"

var dialog_active := false

func _ready() -> void:
	if not npc_data:
		push_error("Kein NPCData zugewiesen für " + name)
		return

	# SpriteFrames & Name setzen
	animated_sprite.sprite_frames = npc_data.sprite_frames
	name_label.text = npc_data.npc_name
	name_label.visible = false

	# Anfangs-Ausrichtung
	_set_facing(npc_data.start_facing)

	# Interactable vorbereiten
	interactable.interact_name = "Press F to talk"
	interactable.interact = _on_interact
	interactable.is_interactable = false

	# Signale verbinden
	interactable.connect("body_entered", Callable(self, "_on_interactable_body_entered"))
	interactable.connect("body_exited", Callable(self, "_on_interactable_body_exited"))

	interact_range.connect("body_entered", Callable(self, "_on_range_entered"))
	interact_range.connect("body_exited", Callable(self, "_on_range_exited"))

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


# Spieler betritt InteractRange
func _on_range_entered(body: Node) -> void:
	if body == player:
		name_label.visible = true
		if not dialog_active:
			interactable.is_interactable = true

		if player.has_node("InteractingComponent"):
			var ic = player.get_node("InteractingComponent")
			ic._on_interact_range_area_entered(interactable)


# Spieler verlässt InteractRange
func _on_range_exited(body: Node) -> void:
	if body == player:
		name_label.visible = false
		interactable.is_interactable = false

		if player.has_node("InteractingComponent"):
			var ic = player.get_node("InteractingComponent")
			ic._on_interact_range_area_exited(interactable)


# Interaktion starten
func _on_interact() -> void:
	if dialog_active or not npc_data.can_talk:
		return

	if npc_data.dialog_timeline_path == "":
		push_warning(npc_data.npc_name + " hat keine Dialog-Timeline zugewiesen.")
		print("[WARNING] ", npc_data.npc_name, " hat keine Dialog-Timeline zugewiesen.")
		return

	dialog_active = true
	interactable.is_interactable = false
	if player:
		#player.can_move = false -> klappt gerade noch nicht
		if player.has_node("InteractingComponent"):
			var ic = player.get_node("InteractingComponent")
			ic.can_interact = false  # Sperre F-Taste während Dialog

	# Dialog starten
	var dialog = Dialogic.start(npc_data.dialog_timeline_path)
	if dialog:
		get_tree().root.add_child(dialog)
		dialog.connect("timeline_ended", Callable(self, "_on_dialog_ended"))


# Dialog beendet
func _on_dialog_ended() -> void:
	dialog_active = false

	if player:
		player.can_move = true
		if player.has_node("InteractingComponent"):
			var ic = player.get_node("InteractingComponent")
			ic.can_interact = true  # F-Taste wieder aktiv

	if player_in_range():
		interactable.is_interactable = true


func _on_interactable_body_entered(_body: Node):
	pass

func _on_interactable_body_exited(_body: Node):
	pass

func player_in_range() -> bool:
	return interact_range.get_overlapping_bodies().has(player)
