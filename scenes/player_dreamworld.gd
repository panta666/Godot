extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
var last_facing_direction = 1

#Variablen für double jump
var jump_count = 0
const MAX_JUMPS = 2  # 1 Boden + 1 Double Jump
var double_jump_allowed: bool = true

#Variablen für Coyote Time
@export var coyote_time: float = 0.15
var coyote_timer: float = 0.0

#Variablen für Dashing
const DASH_SPEED = 700.0
const DASH_DURATION = 0.1
var dash_timer = 0.0
var is_dashing = false
var dash_allowed: bool = true

#Variablen für Crouching
const CROUCH_SPEED:float = 100
var is_crouching: bool = false

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y < 0 and player_sprite.animation != "jump":
			player_sprite.play("jump")
		elif player_sprite.animation != "fall" and player_sprite.animation != "jump":
			player_sprite.play("fall")

	#Coyote Timer neu setzen/ runterzählen
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(coyote_timer - delta, 0)

	# Handle jump (double jump)
	if not is_dashing:
		if Input.is_action_just_pressed("jump"):
			# Erster Sprung / Coyote Time
			if is_on_floor() or coyote_timer > 0.0:
				velocity.y = JUMP_VELOCITY
				jump_count = 1
				coyote_timer = 0.0		#Coyote Time aufbrauchen
				player_sprite.play("jump")
			# Zweiter Sprung wenn erlaubt
			elif double_jump_allowed:
				player_sprite.play("jump")
				if jump_count == 0:		#Falls man runterfällt (nur ein luft jump)
					velocity.y = JUMP_VELOCITY
					jump_count = 2
				elif jump_count == 1:	#Einfacher double jump
					velocity.y = JUMP_VELOCITY
					jump_count = 2

		# Jump Count auf 0 wenn boden berührt wird
		if is_on_floor() and velocity.y == 0:
			jump_count = 0
	
		# Movement
		if not is_crouching:
			var direction := Input.get_axis("move_left", "move_right")
			if direction:
				velocity.x = direction * SPEED
				last_facing_direction = direction
				if is_on_floor() and player_sprite.animation != "run":
					player_sprite.play("run")
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				if is_on_floor() and player_sprite.animation != "idle":
					player_sprite.play("idle")

	#Handle-Dash
	if Input.is_action_just_pressed("dash") and dash_timer <= 0:
		if dash_allowed:
			var direction = Input.get_axis("move_left", "move_right")
			if direction == 0:	#Dash in Blickrichtung
				direction = last_facing_direction
			is_dashing = true
			velocity.x = direction * DASH_SPEED	
			dash_timer = DASH_DURATION
	
	#Dash Aktiv ?
	if is_dashing:
		dash_timer -= delta	#Dash Timer runterzählen
		if dash_timer <= 0:
			is_dashing = false
	
	#Handle Crouching
	if Input.is_action_pressed("crouch") and is_on_floor():
		if not is_dashing:
			is_crouching = true
			var direction := Input.get_axis("move_left", "move_right")
			velocity.x = direction * CROUCH_SPEED
			if direction == 0:
				if player_sprite.animation != "duck":
					player_sprite.play("duck")
					print("duck")
			else:
				last_facing_direction = direction
				if player_sprite.animation != "crouch":
					player_sprite.play("crouch")
					print("crouch")
	else:
		is_crouching = false
		
				
	#Sprite-Flip
	player_sprite.flip_h = (last_facing_direction < 0)
	
	move_and_slide()
	
