extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
var last_facing_direction = 1

#Variablen für Collision anpassung
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var head_check: RayCast2D = $HeadCheck

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
var dash_cooldown = 0.2
var can_dash = true
var is_dashing = false
var dash_count = 1
var dash_allowed: bool = true

#Variablen für Crouching
var forced_crouch: bool
const CROUCH_SPEED:float = 100
var is_crouching: bool = false

#Variablen für Attack
var is_attacking = false
@onready var hit_box_left: HitBox = $HitBoxLeft
@onready var hit_box_right: HitBox = $HitBoxRight
@onready var hit_box_down: HitBox = $HitBoxDown
@onready var hit_box_up: HitBox = $HitBoxUp


#Variablen für Damage nehmen /Knockback
var is_taking_damage: bool = false
var knockback_timer = 0.0
var knockback_length = 0.2

#HP
var is_alive: bool = true
@onready var health_wave: Control = $CanvasLayer/HealthWave
@onready var health: Health = $Health

func _ready() -> void:
	hit_box_left.monitoring = false
	hit_box_right.monitoring = false
	hit_box_down.monitoring = false
	hit_box_up.monitoring = false
	
	hit_box_left.monitorable = false
	hit_box_right.monitorable = false
	hit_box_up.monitorable = false
	hit_box_down.monitorable = false
	
	health_wave.set_health_component(health)


func _physics_process(delta: float) -> void:
	if not is_alive:
		update_animation()
		return
	
	if is_taking_damage:
		add_gravity(delta)
		apply_knockback(delta)
		player_sprite.flip_h = (last_facing_direction < 0)
		update_animation()
		move_and_slide()
		return
	forced_crouch = head_check.is_colliding()
	
	# Add gravity
	add_gravity(delta)

	#Coyote Timer neu setzen/ runterzählen
	handle_coyote_time(delta)

	# Handle jump (double jump)
	if not is_dashing:
		if Input.is_action_just_pressed("jump"):
			handle_jump()
		# Jump Count auf 0 wenn boden berührt wird
		if is_on_floor() and velocity.y == 0:
			jump_count = 0
			dash_count = 1

		# Movement
		if not is_crouching:
			handle_movement()

	#Handle-Dash
	if Input.is_action_just_pressed("dash") and can_dash and dash_timer <= 0 and dash_count == 1 and forced_crouch == false:
		handle_dash()

	#Dash Aktiv ?
	stop_dashing(delta)

	#Handle Crouching
	if Input.is_action_pressed("crouch") or forced_crouch and is_on_floor():
		handle_crouching()
	else:
		stop_crouching()

	#Handle Attack
	if Input.is_action_just_pressed("attack"):
		handle_attack()
	
	#Sprite-Flip
	player_sprite.flip_h = (last_facing_direction < 0)
	
	update_animation()

	move_and_slide()



#Handle Gravity
func add_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
		collision_shape.shape.size = Vector2(14.0, 24.5)
		collision_shape.position = Vector2(0.0, -6.25)
		player_sprite.position.y = 0.0
	else:
		# Standard-Collision (Idle)
		collision_shape.shape.size = Vector2(14.0, 39.0)
		collision_shape.position = Vector2(0.0, 1.0)
		player_sprite.position.y = 0.0

#Handle Movement
func handle_movement():
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		last_facing_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

#Handle Coyote-Time
func handle_coyote_time(delta: float):
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(coyote_timer - delta, 0)

#Handle Jump and Double Jump
func handle_jump():
	# Erster Sprung / Coyote Time
	if is_on_floor() or coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		jump_count = 1
		coyote_timer = 0.0		#Coyote Time aufbrauchen
	# Zweiter Sprung wenn erlaubt
	elif double_jump_allowed:
		if jump_count == 0:		#Falls man runterfällt (nur ein luft jump)
			velocity.y = JUMP_VELOCITY
			jump_count = 2
		elif jump_count == 1:	#Einfacher double jump
			velocity.y = JUMP_VELOCITY
			jump_count = 2

#Handle Dash
func handle_dash():
	if dash_allowed:
		var direction = Input.get_axis("move_left", "move_right")
		if direction == 0:	#Dash in Blickrichtung
			direction = last_facing_direction
		is_dashing = true
		dash_count = 0
		can_dash = false
		velocity.x = direction * DASH_SPEED
		dash_timer = DASH_DURATION

func handle_crouching():
	if not is_dashing:
		is_crouching = true
		collision_shape.shape.size = Vector2(14.0, 29.0)
		collision_shape.position = Vector2(0.0, 6.0)
		player_sprite.position.y = 5.0
		var direction := Input.get_axis("move_left", "move_right")
		velocity.x = direction * CROUCH_SPEED
		if direction != 0:
			last_facing_direction = direction

func stop_crouching():
	is_crouching = false
	collision_shape.shape.size = Vector2(14.0, 39.0)
	collision_shape.position = Vector2(0.0, 1.0)
	player_sprite.position.y = 0.0

func stop_dashing(delta: float):
	if is_dashing:
		dash_timer -= delta		#Dash Timer runterzählen
		if dash_timer <= 0:
			is_dashing = false
			await get_tree().create_timer(dash_cooldown).timeout
			can_dash = true

#Handle Attack
func handle_attack():
	if is_attacking:
		return
	
	is_attacking = true
	if Input.is_action_pressed("move_up"):
		hit_box_up.monitoring = true
		hit_box_up.monitorable = true
		print("up_attack")
	elif Input.is_action_pressed("move_down") and not is_on_floor():
		hit_box_down.monitoring = true
		hit_box_down.monitorable = true
		print("down_attack")
	elif last_facing_direction > 0:
		hit_box_right.monitorable = true
		hit_box_right.monitoring = true
		print("right_attack")
	else:
		hit_box_left.monitorable = true
		hit_box_left.monitoring = true
		print("left_attack")

	await player_sprite.animation_finished

	hit_box_down.monitoring = false
	hit_box_down.monitorable = false
	hit_box_up.monitoring = false
	hit_box_up.monitorable = false
	hit_box_right.monitorable = false
	hit_box_left.monitorable = false
	hit_box_right.monitoring = false
	hit_box_left.monitoring = false
	is_attacking = false


#Handle Take Damage
func received_damage(damage: int) -> void:
	if is_dashing:
		return
	if is_taking_damage:
		return
	is_taking_damage = true
	is_attacking = false
	is_crouching = false

	# Knockbackrichtung
	var knock_dir = -sign(last_facing_direction)
	if knock_dir == 0:
		knock_dir = -1

	# Rückstoßgeschwindigkeit
	velocity.x = knock_dir * 250.0
	velocity.y = -80.0 

	knockback_timer = knockback_length

	print("Player takes", damage, "damage!")
	print("Player HP: ", health.get_health())

#Apply Knockback on Hit taken
func apply_knockback(delta: float):
	if is_taking_damage:
		knockback_timer -= delta
		if knockback_timer <= 0:
			is_taking_damage = false
			velocity.x = 0
			stop_dashing(delta)

#Handle Death
func _on_health_depleted() -> void:
	if not is_alive:
		return
	
	is_alive = false
	is_taking_damage = false
	is_attacking = false
	is_dashing = false
	is_crouching = false
	velocity = Vector2.ZERO
	
	player_sprite.play("die")
	
	await player_sprite.animation_finished
	get_tree().change_scene_to_file("res://scenes/realworld_classroom_one.tscn")



#Animationen updaten
func update_animation():
	if not is_alive:
		return

	if is_taking_damage:
		if player_sprite.animation != "take_damage":
			player_sprite.play("take_damage")
		return

	if is_attacking:
		if player_sprite.animation != "attack":
			if Input.is_action_pressed("move_up"):
				player_sprite.play("attack_up")
			elif Input.is_action_pressed("move_down"):
				player_sprite.play("attack_down")
			else:
				player_sprite.play("attack")
		return

	if is_dashing:
		if player_sprite.animation != "dash":
			player_sprite.play("dash")
		return

	if not is_on_floor():
		if velocity.y < 0:
			if player_sprite.animation != "jump":
				player_sprite.play("jump")
		else:
			if player_sprite.animation != "fall":
				player_sprite.play("fall")
	elif is_crouching:
		if abs(velocity.x) > 0:
			if player_sprite.animation != "crouch":
				player_sprite.play("crouch")
		else:
			if player_sprite.animation != "duck":
				player_sprite.play("duck")
	else:
		if abs(velocity.x) > 10:
			if player_sprite.animation != "run":
				player_sprite.play("run")
		else:
			if player_sprite.animation != "idle":
				player_sprite.play("idle")

#Handle Down-Attack
func _on_hit_box_down_body_entered(body: Node2D) -> void:
	if not is_attacking:
		return
	if not Input.is_action_pressed("move_down"):
		return
	if is_on_floor():
		return
	
	# Bounce nach oben
	if body.is_in_group("enemy"):
		print("Down-Hit auf Gegner:", body.name)
		velocity.y = JUMP_VELOCITY
		print("Bounce Jump")
