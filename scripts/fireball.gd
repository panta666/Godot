extends CharacterBody2D


const SPEED = 300.0
var direction: float
@onready var fireball_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

func _physics_process(delta: float) -> void:
	#Sprite-Flip
	fireball_sprite.flip_h = (direction > 0)
	move_local_x(direction * SPEED * delta)
	
	if ray_cast_2d.is_colliding(): #Collision mit Wänden
		fireball_sprite.play("death")
		await fireball_sprite.animation_finished
		queue_free()

func _on_hit_box_area_entered(area: Area2D) -> void: #Collision mit Gegnern
	fireball_sprite.play("death")
	await fireball_sprite.animation_finished
	queue_free()
