extends CharacterBody2D


const SPEED = 300.0
var direction: float
@onready var fireball_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

var current_scene
var scene_name

var is_dead = false

func _ready():
	current_scene = get_tree().current_scene
	scene_name = current_scene.name.to_lower()
	
	change_size()

func _physics_process(delta: float) -> void:
	move_local_x(direction * SPEED * delta)
	
	play_run_animation()
	
	if ray_cast_2d.is_colliding(): #Collision mit Wänden
		play_death_animation()

func _on_hit_box_area_entered(_area: Area2D) -> void: #Collision mit Gegnern
	play_death_animation()

func play_run_animation():
	if is_dead == true:
		return
	if "oop" in scene_name:
		fireball_sprite.play("oop_run")
	elif "math" in scene_name:
		fireball_sprite.play("math_run")
	else:
		fireball_sprite.play("run")

func change_size():
	if "oop" in scene_name:
		fireball_sprite.flip_h = (direction < 0)
		fireball_sprite.scale = Vector2(0.065,0.085)
		fireball_sprite.position = Vector2(-22, -1)
	elif "math" in scene_name:
		fireball_sprite.flip_h = (direction < 0)
		fireball_sprite.scale = Vector2(0.069, 0.066)
		fireball_sprite.position = Vector2(-27, -1)
	else:
		fireball_sprite.flip_h = (direction > 0)
		fireball_sprite.scale = Vector2(0.584, 0.556)
		fireball_sprite.position = Vector2(-13, 0)

func play_death_animation():
	is_dead = true
	if "oop" in scene_name:
		fireball_sprite.play("oop_death")
	elif "math" in scene_name:
		fireball_sprite.play("math_death")
	else:
		fireball_sprite.play("death")
	await fireball_sprite.animation_finished
	queue_free()
