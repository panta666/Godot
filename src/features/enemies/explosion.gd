extends Node2D
class_name Explosion

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: HitBox = $HitBox

@export var duration := 0.5
@export var damage := 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer := $Timer
	timer.wait_time = duration
	timer.start()
	_play_animation_scaled("explosion", duration)
	hitbox.damage = damage

func _play_animation_scaled(name: String, duration: float) -> void:
	var frames := sprite.sprite_frames
	var speed := (frames.get_frame_count(name)-1) / duration
	frames.set_animation_speed(name, speed)
	sprite.play(name)
	

	
func _on_timer_timeout() -> void:
	queue_free()
