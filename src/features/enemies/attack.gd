extends Resource
class_name Attack

enum movement_type {
	DASH,
	NONE,
	WALK
}

@export var damage: int
@export var pre_attack_duration: float
@export var post_attack_duration: float
@export var animation_name: String
@export var pre_animation_name: String
@export var post_animation_name: String
@export var movement: movement_type
@export var hitbox_offset: Vector2
@export var hitbox_size: Vector2
@export var hitbox_duration: float
