extends "res://src/features/enemies/generic_enemy.gd"
class_name Ghost

# -------------------------------------------------------------------
# CONFIG
# -------------------------------------------------------------------
@export var number_position := Vector2(-17, -35)

var number 

var invincible := false

var text

#Primzahlen-Array
var primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

#Nicht-Primzahlen-Array
var non_primes = [1, 4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 22, 24, 25, 26, 27, 28, 30, 32, 33, 34,
				 35, 36, 38, 39, 40, 42, 44, 45, 46, 48, 49, 50, 51, 52, 54, 55, 56, 57, 58, 60, 62, 63, 64, 
				 65, 66, 68, 69, 70, 72, 74, 75, 76, 77, 78, 80, 81, 82, 84, 85, 86, 87, 88, 90, 91, 92, 93, 
				 94, 95, 96, 98, 99]

#---------------
#RESOURCES
#---------------
var number_scene := preload("res://src/features/enemies/ghost_number.tscn")
var aoe = preload("res://src/features/enemies/ghost_aoe.tres")

@onready var health = $Health

func _ready():
	call_deferred("_spawn_healthbar")
	call_deferred("spawn_number")
	
#-------------------------
# Hurt System Logic
#-------------------------
# Zahl-Szene wird über dem Geist instanziiert
func spawn_number() -> void:
	number = number_scene.instantiate()
	get_tree().root.add_child(number)
	number.position = global_position + number_position
	text = number.get_child(0)
	generate_number()
	
#Zahl-Szene Position wird angepasst
func _process(delta):
	number.position = global_position + number_position
	
#Mit bestimmter Wahrscheinlichkeit zufällige Primzahl oder Nicht-Primzahl aus dem Array setzen
#Geist Immortality abhängig von Zufalsszahl setzen
func generate_number() -> void:
	if randi_range(1, 3) == 2:
		invincible = false
		health.immortality = false
		text.text = str(primes.pick_random())
	else:
		invincible = true
		health.immortality = true
		text.text = str(non_primes.pick_random())
	
	await get_tree().create_timer(8).timeout
	generate_number()
		
# Szene löschen, wenn Leben leer
func _on_health_depleted() -> void:
	healthbar._deplete()
	call_deferred("drop_item")
	number.queue_free()
	queue_free()
	
# Wenn Geist nicht invincible ist, Schaden hinzufügen, sonst Hitbox aktivieren
func _on_hurt_box_received_damage(damage: int, attacker_pos: Vector2) -> void:
	if not invincible:
		flash_anim.play("flash")
		_apply_knockback(attacker_pos)
		healthbar.update()
		damaged.emit(damage)
		GlobalScript.enemy_damaged.emit(damage)
		_stun()
	else:
		hitbox.disabled = true
		await get_tree().physics_frame
		hitbox.disabled = false
		await get_tree().create_timer(0.5).timeout
		hitbox.disabled = true
		

		
	
	
