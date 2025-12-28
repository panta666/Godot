@tool
extends Node2D

@export_category("Visible Keys")
@export var show_w: bool = false:
	set(value):
		show_w = value
		_update_keys()

@export var show_a: bool = false:
	set(value):
		show_a = value
		_update_keys()

@export var show_s: bool = false:
	set(value):
		show_s = value
		_update_keys()

@export var show_d: bool = false:
	set(value):
		show_d = value
		_update_keys()

@export var show_space: bool = false:
	set(value):
		show_space = value
		_update_keys()

@export var show_shift: bool = false:
	set(value):
		show_shift = value
		_update_keys()


@export_category("Animated Keys")
@export var animate_w: bool = false:
	set(value):
		animate_w = value
		_update_keys()

@export var animate_a: bool = false:
	set(value):
		animate_a = value
		_update_keys()

@export var animate_s: bool = false:
	set(value):
		animate_s = value
		_update_keys()

@export var animate_d: bool = false:
	set(value):
		animate_d = value
		_update_keys()

@export var animate_space: bool = false:
	set(value):
		animate_space = value
		_update_keys()

@export var animate_shift: bool = false:
	set(value):
		animate_shift = value
		_update_keys()


@onready var key_w: AnimatedSprite2D = $KEY_W
@onready var key_a: AnimatedSprite2D = $KEY_A
@onready var key_s: AnimatedSprite2D = $KEY_S
@onready var key_d: AnimatedSprite2D = $KEY_D
@onready var key_shift: AnimatedSprite2D = $KEY_SHIFT
@onready var key_space: AnimatedSprite2D = $KEY_SPACE


func _ready():
	_update_keys()


func _update_keys():
	_set_key(key_w, show_w, animate_w)
	_set_key(key_a, show_a, animate_a)
	_set_key(key_s, show_s, animate_s)
	_set_key(key_d, show_d, animate_d)
	_set_key(key_space, show_space, animate_space)
	_set_key(key_shift, show_shift, animate_shift)


func _set_key(sprite: AnimatedSprite2D, visible: bool, animate: bool):
	if not sprite:
		return

	sprite.visible = visible

	if not visible:
		return

	if animate:
		sprite.play()
	else:
		sprite.stop()
		sprite.frame = 0
