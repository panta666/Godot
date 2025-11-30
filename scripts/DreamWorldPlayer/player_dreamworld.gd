extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -320.0 #-300
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
var last_facing_direction = 1
const CLIMB_SPEED = 200

#Variable für Leiter
var on_ladder: bool
var climbing: bool

#Variablen für Collision anpassung
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var head_check: RayCast2D = $HeadCheck

#Variablen für double jump
var is_double_jump_allowed: bool = true # false
var jump_count = 0
const MAX_JUMPS = 2  # 1 Boden + 1 Double Jump
var is_double_jumping: bool = false

#Variablen für Coyote Time
@export var coyote_time: float = 0.15
var coyote_timer: float = 0.0

#Variablen für Dashing
var is_dash_allowed: bool = false
const DASH_SPEED = 700.0
const DASH_DURATION = 0.1
var dash_timer = 0.0
var dash_cooldown = 0.2
var can_dash = true
var is_dashing = false
var dash_count = 1
@onready var hurt_box: HurtBox = $HurtBox
@onready var dash_particles: GPUParticles2D = $DashParticles

#Variablen für Crouching
var is_crouching_allowed: bool = false
var forced_crouch: bool
const CROUCH_SPEED:float = 100
var is_crouching: bool = false

#Variablen für Attacke
var is_attacking = false

const ATTACK_COOLDOWN = 0.5
var attack_timer = 0.0
var can_attack = true

@onready var hit_box_left: HitBox = $HitBoxLeft
@onready var hit_box_right: HitBox = $HitBoxRight
@onready var hit_box_down: HitBox = $HitBoxDown
@onready var hit_box_up: HitBox = $HitBoxUp

@onready var sprite_right_hitbox: AnimatedSprite2D = $HitBoxRight/SpriteRightHitbox
@onready var sprite_left_hitbox: AnimatedSprite2D = $HitBoxLeft/SpriteLeftHitbox
@onready var sprite_up_hitbox: AnimatedSprite2D = $HitBoxUp/SpriteUpHitbox
@onready var sprite_down_hitbox: AnimatedSprite2D = $HitBoxDown/SpriteDownHitbox

#Variablen für Range Attacke
var is_range_attack_allowed: bool = false
var max_range_attack = 1 #Wie viele Charges man hat
@onready var fireball = preload("res://scenes/DreamworldPlayer/fireball.tscn")
var current_range_attack = 0
const RANGE_ATTACK_RECHARGE_TIME = 5.0
var recharge_timer = 0.0
@onready var range_attack_charges: TextureButton = $RangeAttackCharges/RangeAttackCharges

#Variablen für Damage nehmen/ Knockback
var is_taking_damage: bool = false
var knockback_timer = 0.0
var knockback_length = 0.2
@onready var hit_flash_animation: AnimationPlayer = $AnimatedSprite2D/AnimationPlayer

#HP
var is_alive: bool = true
@onready var health_wave: Control = $Healthwave/HealthWave
@onready var health: Health = $Health
var blink_overlay_scene = preload("res://scenes/components/blink_overlay.tscn")

@onready var camera_2d: Camera2D = $Camera2D

func _ready() -> void:
	deactivate_hitboxes()

	health_wave.set_health_component(health)

	player_sprite.animation_finished.connect(_on_animation_finished)
	if Player_Realworld != null:
		Player_Realworld.disable_player()
	if camera_2d:
			camera_2d.make_current()

	range_attack_charges.update_charge_text(current_range_attack, max_range_attack)

	player_sprite.material.set_shader_parameter("flash_value", 0.0)

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
	
	print(on_ladder)

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

	#Dash Aktiv ?
	stop_dashing(delta)

	#Handle-Dash
	if Input.is_action_just_pressed("dash") and can_dash and dash_timer <= 0 and dash_count == 1 and forced_crouch == false:
		handle_dash()

	#Handle Crouching
	if Input.is_action_pressed("crouch") or forced_crouch and is_on_floor():
		handle_crouching()
	else:
		stop_crouching()

	#Handle Attack_Timner
	countdown_attack_timer(delta)

	#Handle Attack
	if Input.is_action_just_pressed("attack"):
		handle_attack()

	#Handle Range Attack
	if Input.is_action_just_pressed("range_attack"):
		handle_range_attack()

	handle_range_recharge(delta)

	#Sprite-Flip
	player_sprite.flip_h = (last_facing_direction < 0)
	dash_particles.scale.x = last_facing_direction

	#Fähigkeiten aktivieren, wird später entfernt
	if Input.is_action_just_pressed("activate_crouching"):
		activate_crouching()
	if Input.is_action_just_pressed("activate_dash"):
		activate_dash()
	if Input.is_action_just_pressed("activate_double_jump"):
		activate_double_jump()
	if Input.is_action_just_pressed("activate_range_attack"):
		activate_range_attack()
	if Input.is_action_just_pressed("increase_range_attack_charges"):
		increase_range_attack_charges()

	update_animation()

	move_and_slide()
	
	
	if on_ladder:
		if Input.is_action_pressed("move_down"):
			velocity.y = SPEED*delta*40
		elif Input.is_action_pressed("jump"):
			velocity.y = -SPEED*delta*40
		else: 
			velocity.y = 0

func deactivate_hitboxes():
	hit_box_left.monitoring = false
	hit_box_right.monitoring = false
	hit_box_down.monitoring = false
	hit_box_up.monitoring = false

	hit_box_left.monitorable = false
	hit_box_right.monitorable = false
	hit_box_up.monitorable = false
	hit_box_down.monitorable = false

	sprite_right_hitbox.visible = false
	sprite_left_hitbox.visible = false
	sprite_down_hitbox.visible = false
	sprite_up_hitbox.visible = false

#Handle Gravity
func add_gravity(delta: float) -> void:
	if not is_on_floor() and !on_ladder:
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
	elif is_double_jump_allowed:
		if jump_count == 0:		#Falls man runterfällt (nur ein luft jump)
			velocity.y = JUMP_VELOCITY
			jump_count = 2
			is_double_jumping = true
		elif jump_count == 1:	#Einfacher double jump
			velocity.y = JUMP_VELOCITY
			jump_count = 2
			is_double_jumping = true

#Handle Dash
func handle_dash():
	if is_dash_allowed:
		var direction = Input.get_axis("move_left", "move_right")
		if direction == 0:	#Dash in Blickrichtung
			direction = last_facing_direction
		is_dashing = true
		dash_particles.emitting = true
		hurt_box.monitoring = false
		hurt_box.monitorable = false
		dash_count = 0
		can_dash = false
		velocity.x = direction * DASH_SPEED
		dash_timer = DASH_DURATION

func handle_crouching():
	if not is_dashing and is_crouching_allowed:
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
			hurt_box.monitoring = true
			hurt_box.monitorable = true
			await get_tree().create_timer(dash_cooldown).timeout
			can_dash = true
			dash_particles.emitting = false

#Handle Attack
func handle_attack():
	if is_attacking or not can_attack:
		return

	is_attacking = true
	can_attack = false
	attack_timer = ATTACK_COOLDOWN

	if Input.is_action_pressed("move_up"):
		play_slash(sprite_up_hitbox, hit_box_up)
	elif Input.is_action_pressed("move_down") and not is_on_floor():
		play_slash(sprite_down_hitbox, hit_box_down)
	elif last_facing_direction > 0:
		play_slash(sprite_right_hitbox, hit_box_right)
	else:
		play_slash(sprite_left_hitbox, hit_box_left)


#Handle Range Attack
func handle_range_attack():
	if is_attacking:
		return
	
	if not is_range_attack_allowed:
		return
	
	if current_range_attack <= 0:
		print("Keine Charges!")
		return

	is_attacking = true

	await player_sprite.animation_finished

	is_attacking = false

	current_range_attack -= 1
	range_attack_charges.update_charge_text(current_range_attack, max_range_attack)
	print("Range Attack! Charges übrig:", current_range_attack)

	if current_range_attack < max_range_attack and recharge_timer <= 0:
		recharge_timer = RANGE_ATTACK_RECHARGE_TIME
		recharge_timer = RANGE_ATTACK_RECHARGE_TIME
		range_attack_charges.update_recharge_progress(0.0)

	var f = fireball.instantiate()

	if last_facing_direction > 0: #nach Rechts schießen
		f.position = global_position + Vector2(20, 0)
		f.direction = 1
		print("right_range")
	else:	#nach Links schießen
		f.direction = -1
		print("left_range")
		f.position = global_position + Vector2(-20, 0)
		
	get_parent().add_child(f)

#Handle Recharge Timer für Range Attacke
func handle_range_recharge(delta):
	if not is_range_attack_allowed:
		range_attack_charges.visible = false
	else:
		range_attack_charges.visible = true

	if current_range_attack >= max_range_attack:
		range_attack_charges.update_recharge_progress(1.0) # Voll = 100%
		return

	recharge_timer -= delta

	var progress: float = clamp(1.0 - (recharge_timer / RANGE_ATTACK_RECHARGE_TIME), 0.0, 1.0)
	range_attack_charges.update_recharge_progress(progress)

	if recharge_timer <= 0:
		current_range_attack += 1
		range_attack_charges.update_charge_text(current_range_attack, max_range_attack)

		if current_range_attack < max_range_attack:
			recharge_timer = RANGE_ATTACK_RECHARGE_TIME
		else:
			range_attack_charges.update_recharge_progress(1.0)



#Handle Attack Cooldown
func countdown_attack_timer(delta: float):
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true

#Damit man nicht in Animation stuck ist
func _on_animation_finished():
	if player_sprite.animation.begins_with("attack") or player_sprite.animation.begins_with("range_attack"):
		is_attacking = false



#Handle Slash-Animation
func play_slash(sprite: AnimatedSprite2D, hitbox: Area2D):
	hitbox.monitorable = true
	hitbox.monitoring = true
	sprite.visible = true
	sprite.play("slash")
	sprite.animation_finished.connect(func ():
		hitbox.monitorable = false
		hitbox.monitoring = false
		sprite.visible = false
	)



#Handle Take Damage
func received_damage(_damage: int) -> void:
	if is_dashing:
		return
	if is_taking_damage:
		return
	is_taking_damage = true
	is_attacking = false
	is_crouching = false

	hit_flash_animation.play("hit_flash")

	# Knockbackrichtung
	var knock_dir = -sign(last_facing_direction)
	if knock_dir == 0:
		knock_dir = -1

	# Rückstoßgeschwindigkeit
	velocity.x = knock_dir * 250.0
	velocity.y = -80.0

	knockback_timer = knockback_length

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

	print("dead")

	player_sprite.play("die")
	await get_tree().create_timer(0.7).timeout
	player_sprite.position.y = 15.0
	await player_sprite.animation_finished

	# Death-Screen zeigen
	await show_death_screen()

	await blink_overlay("res://scenes/realworld_classroom_one.tscn")

func show_death_screen():
	var scene = preload("res://scenes/components/death_screen.tscn")
	var death_screen = scene.instantiate() as CanvasLayer
	get_tree().root.add_child(death_screen)

	await death_screen.play_screen()
	await get_tree().create_timer(1.0).timeout

	death_screen.queue_free()

func blink_overlay(next_scene_path: String) -> void:
	if blink_overlay_scene:
		var overlay = blink_overlay_scene.instantiate() as CanvasLayer
		get_tree().root.add_child(overlay)

		var blink_rect = overlay.get_node("Blink_Overlay") as ColorRect
		blink_rect.play_wake_up(next_scene_path)


#Animationen updaten
func update_animation():
	if not is_alive:
		return

	if is_taking_damage:
		if player_sprite.animation != "take_damage":
			player_sprite.play("take_damage")
		return

	# Double Jump Animation läuft
	if is_double_jumping:
		if player_sprite.animation != "frontflip":
			player_sprite.play("frontflip")
		# Sobald man aufhört aufzusteigen -> Flip endet 
		if velocity.y >= 0:
			is_double_jumping = false
		return

	if is_attacking:
		if player_sprite.animation != "attack":
			if Input.is_action_pressed("move_up"):
				player_sprite.play("attack_up")
			elif Input.is_action_pressed("move_down") and not is_on_floor():
				player_sprite.play("attack_down")
			elif Input.is_action_pressed("range_attack"):
				player_sprite.play("range_attack")
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
		is_double_jumping = true

func _input(event: InputEvent):
	if(event.is_action_pressed("move_down") && is_on_floor()):
		position.y += 1

func player():
	pass

func activate_crouching():
	is_crouching_allowed = true

func activate_range_attack():
	is_range_attack_allowed = true

func activate_double_jump():
	is_double_jump_allowed = true

func activate_dash():
	is_dash_allowed = true

func increase_range_attack_charges():
	max_range_attack += 1
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	on_ladder = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	on_ladder = false
