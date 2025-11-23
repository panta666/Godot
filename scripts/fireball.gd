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
	scene_name = current_scene.name
	
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
	if "Level_one" in scene_name:
		fireball_sprite.play("oop_run")
	elif "medg" in scene_name:
		#fireball_sprite.play("medg_run")
		pass
	else:
		fireball_sprite.play("run")

func change_size():
	if "Level_one" in scene_name:
		fireball_sprite.flip_h = (direction < 0)
		fireball_sprite.scale = Vector2(0.094,0.154)
		fireball_sprite.position = Vector2(-20, -1)
	elif "medg" in scene_name:
		fireball_sprite.flip_h = (direction < 0)
		fireball_sprite.scale = Vector2(1,1)
		fireball_sprite.position = Vector2(0, 0)
	else:
		fireball_sprite.flip_h = (direction < 0)
		fireball_sprite.scale = Vector2(1, 1)
		fireball_sprite.position = Vector2(0, 0)

func play_death_animation():
	is_dead = true
	if "Level_one" in scene_name:
		fireball_sprite.play("oop_death")
	elif "medg" in scene_name:
		#fireball_sprite.play("medg_death")
		pass
	else:
		fireball_sprite.play("death")
	await fireball_sprite.animation_finished
	queue_free()
