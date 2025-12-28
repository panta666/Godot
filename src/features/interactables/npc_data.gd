@tool
extends Resource
class_name NPCData

# --- Grunddaten ---
@export var npc_name: String = "NPC"
@export var sprite_frames: SpriteFrames

# --- Animationen ---
@export var idle_up: String = "idle_up"
@export var idle_down: String = "idle_down"
@export var idle_side: String = "idle_side"

@export var walk_up: String = "walk_up"
@export var walk_down: String = "walk_down"
@export var walk_side: String = "walk_side"
@export var sit: String = "sit"

@export var can_sit: bool = false:
	set(value):
		can_sit = value
		notify_property_list_changed()

enum SitDirection { RIGHT, LEFT }
@export var sit_direction: SitDirection = SitDirection.RIGHT

# --- Interaktion & Dialog ---
@export var start_facing: String = "down"
@export var can_talk: bool = true
@export var dialog_timeline_path: String = ""
@export var dialogic_character: Resource

# --- Verhalten-System ---
enum BehaviorType { NONE, IDLE_TURN, RANDOM_WALK, PATROL }
@export var behavior_type: BehaviorType = BehaviorType.NONE

# --- Zufällige Bewegung / Idle-Verhalten ---
@export_range(10, 200, 1) var move_speed: float = 40.0
@export_range(0.5, 10.0, 0.1) var wander_interval: float = 2.5

# --- Patrouillen-Verhalten über Path2D ---
@export var path_node: NodePath                          # referenziert Path2D in der Szene
@export var patrol_wait_time: float = 1.5               # Wartezeit an PathFollow Punkten

func _validate_property(property: Dictionary) -> void:
	# sit_direction nur aktiv wenn can_sit true
	if property["name"] == "sit_direction":
		if not can_sit:
			property["usage"] |= PROPERTY_USAGE_READ_ONLY
		return

	# Diese Felder sollen deaktiviert werden, wenn NPC sitzt
	var disable_when_sit := [
		"start_facing",
		"can_talk",
		"dialog_timeline_path",
		"dialogic_character",
		"behavior_type",
		"move_speed",
		"wander_interval",
		"path_node",
		"patrol_wait_time"
	]

	if can_sit and property["name"] in disable_when_sit:
		property["usage"] |= PROPERTY_USAGE_READ_ONLY
