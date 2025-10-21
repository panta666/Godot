extends CharacterBody2D

const SPEED = 120.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var facing_direction := "down"
var sitting := false
var can_move := true

func _physics_process(_delta: float) -> void:
	if not can_move:
		return 

	# Eingabe lesen (Input Map: move_up, move_down, move_left, move_right)
	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	# Bewegung
	velocity = input_vector * SPEED
	move_and_slide()

	# Animation
	if input_vector == Vector2.ZERO:
		match get_facing_direction():
			"up":
				animated_sprite_2d.play("idle_up")
			"down":
				animated_sprite_2d.play("idle_down")
			"side":
				animated_sprite_2d.play("idle_side")
	else:
		if abs(input_vector.x) > abs(input_vector.y):
			animated_sprite_2d.play("walk_side")
			animated_sprite_2d.flip_h = input_vector.x < 0
			set_facing_direction("side")
		elif input_vector.y < 0:
			animated_sprite_2d.play("walk_up")
			set_facing_direction("up")
		elif input_vector.y > 0:
			animated_sprite_2d.play("walk_down")
			set_facing_direction("down")


func set_facing_direction(dir: String) -> void:
	facing_direction = dir

func get_facing_direction() -> String:
	return facing_direction

# Funktion wodurch man Abfragen kann ob man ein Player ist.
# mit if body.has_method("player"): z.B.
func player():
	pass


func sit_on_chair(target_pos: Vector2):
	global_position = target_pos
	sitting = true
	can_move = false
	velocity = Vector2.ZERO
	animated_sprite_2d.flip_h = false  
	animated_sprite_2d.play("sit")

func stand_up(target_pos: Vector2):
	sitting = false
	can_move = true
	global_position = target_pos
	animated_sprite_2d.play("idle_down")
