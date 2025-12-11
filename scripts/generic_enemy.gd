extends CharacterBody2D

class_name Enemy

@export var attacks: Array[Attack] = []

@export var range_attacks: Array[Range_Attack] = []

var projectile_object = preload("res://scenes/Enemies/Projectile.tscn")

var healthbar_object = preload("res://scenes/Enemies/enemy_health_bar.tscn")

var healthbar

const SPEED = 50.0 #50

const STUN_TIME = 0.35 #0.35

const DASH_SPEED = 300.0 #300

const RANGE = 250 #250

const ATTACK_RANGE_FAR = 166 #166

const ATTACK_RANGE_NEAR = 165 #165

const ATTACK_RANGE = 260 #260

@export var health_bar_position = Vector2(0, -30) #  Vector2(0, -30)

var direction = 1

var is_walking = 1

var dashing = false

var stunned = false

var is_attacking = false

var attack_allowed = true

var player: Node2D = null

@onready var ray_cast_down_right = $RaycastDownRight

@onready var ray_cast_right = $RayCastRight

@onready var sprite = $AnimatedSprite2D

@onready var back_vision = $Vision_Back

@onready var front_vision = $Vision_Front

@onready var tracking_box = $Tracking_Box

@onready var attack_cooldown_timer = $Attack_Cooldown

@onready var enemy_sound_player: Node2D = $EnemySoundPlayer

var knockback_timer = 0.0

var knockback_length = 0.2

@onready var flash_animation: AnimationPlayer = $AnimatedSprite2D/FlashAnimation

func _ready() -> void:
	call_deferred("_spawn_healthbar")



func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor():
		if !is_attacking and !stunned:
			if !ray_cast_down_right.is_colliding() or ray_cast_right.is_colliding():
				direction *= -1
				scale.x *= -1
				$RayCastRight.target_position.x *= -1
			else:
				if _is_player_in_sight():
					if !is_attacking:
						_start_attack()
					if !dashing:
						track_player(player.position)
				else:
					if player != null:
						var bodies = tracking_box.get_overlapping_bodies()
						if player in bodies:
							if !dashing:
								track_player(player.position)
								is_walking = 0
								if sprite.animation != "idle":
									print("idle1")
									sprite.play("idle")
									enemy_sound_player.stop_move_sound()
						else:
							player = null
					else:
						is_walking = 1
						sprite.play("walk")
						enemy_sound_player.play_sound(Enemysound.soundtype.WALK)
		if !stunned:
			if dashing:
				velocity.x = direction * DASH_SPEED * is_walking
			else:
				velocity.x = direction * SPEED * is_walking
		
	move_and_slide()

	
	
func _is_player_in_sight()-> bool:
	var collider: Node2D
	if front_vision.is_colliding():
		collider = front_vision.get_collider()
	if back_vision.is_colliding():
		collider =back_vision.get_collider()
	if collider != null:
		if collider is CharacterBody2D:
			player = collider
			return true
	return false
	
func _stun():
	stunned = true
	print("stun")
	
	var frames: SpriteFrames = sprite.sprite_frames
	var frame_number = frames.get_frame_count("stun")
	var anim_speed = frame_number / STUN_TIME
	frames.set_animation_speed("stun", anim_speed)
	sprite.play("stun")
	await get_tree().create_timer(STUN_TIME).timeout
	stunned = false


	
func track_player(player_position: Vector2):

	var dx = abs(player_position.x - position.x)
	if dx > 15:
		if player_position.x > position.x:
			direction = 1
			transform.x = Vector2(1.0*scale.x, 0.0)
		else:
			direction = -1
			transform.x = Vector2(-1.0*scale.x, 0.0)
		
		ray_cast_right.target_position.x = abs(ray_cast_right.target_position.x) * direction
		
func _start_attack():
	if attack_allowed and !is_attacking:
		attack_allowed = false
		attack_cooldown_timer.start()
		if player != null:
			enemy_sound_player.play_sound(Enemysound.soundtype.ATTACK)
			if range_attacks.is_empty():
				var r  = randi_range(0, attacks.size() - 1)	
				_attack(attacks[r])
			elif attacks.is_empty():
				if player.global_position.distance_to(global_position) < ATTACK_RANGE:
					var r  = randi_range(0, range_attacks.size() - 1)
					_range_attack(range_attacks[r])
			else:
				if player.global_position.distance_to(global_position) > ATTACK_RANGE_FAR:
					var r  = randi_range(0, range_attacks.size() - 1)
					_range_attack(range_attacks[r])
				else:
					if player.global_position.distance_to(global_position) < ATTACK_RANGE_NEAR:
						var r  = randi_range(0, attacks.size() - 1)
						_attack(attacks[r])
		
		
func _attack(attack: Attack):
	is_attacking = true
	var hitbox = $HitBox/CollisionShape2D
	hitbox.position = attack.hitbox_offset
	var shape := hitbox.shape as RectangleShape2D
	shape.extents = attack.hitbox_size
	$HitBox.damage = attack.damage
	var frames: SpriteFrames = sprite.sprite_frames
	
	is_walking = 0
	
	var frame_number = frames.get_frame_count(attack.pre_animation_name)
	var anim_speed = frame_number / attack.pre_attack_duration
	frames.set_animation_speed(attack.pre_animation_name, anim_speed)
	sprite.play(attack.pre_animation_name)
	
	await get_tree().create_timer(attack.pre_attack_duration).timeout
	is_walking = 1
	#sprite.play("walk")
	var attack_duration = attack.hitbox_duration
	
	match attack.movement:
		attack.movement_type.DASH:
			print("is it dashing: ", dashing)
			_start_dash()
			attack_duration = $DashingTimer.wait_time
		attack.movement_type.NONE:
			is_walking = 0
			sprite.play("idle")
	
	hitbox.disabled = false
	
	frame_number = frames.get_frame_count(attack.animation_name)
	anim_speed = frame_number / attack_duration
	frames.set_animation_speed(attack.animation_name, anim_speed)
	sprite.play(attack.animation_name)
	
	await get_tree().create_timer(attack_duration).timeout
	
	hitbox.disabled = true
	
	is_walking = 0
	
	frame_number = frames.get_frame_count(attack.post_animation_name)
	anim_speed = frame_number / attack.post_attack_duration
	frames.set_animation_speed(attack.post_animation_name, anim_speed)
	sprite.play(attack.post_animation_name)
	
	await get_tree().create_timer(attack.post_attack_duration).timeout

	is_attacking = false
	

func _range_attack(attack: Range_Attack):
	is_attacking = true
	var frames: SpriteFrames = sprite.sprite_frames
	
	is_walking = 0
	
	enemy_sound_player.play_sound(Enemysound.soundtype.PRE_ATTAK)
	var frame_number = frames.get_frame_count(attack.pre_animation_name)
	var anim_speed = frame_number / attack.pre_attack_duration
	frames.set_animation_speed(attack.pre_animation_name, anim_speed)
	sprite.play(attack.pre_animation_name)
	await get_tree().create_timer(attack.pre_attack_duration).timeout
	# enemy_sound_player.stop()
	
	enemy_sound_player.play_sound(Enemysound.soundtype.ATTACK)
	var projectile = projectile_object.instantiate()
	projectile.get_node("HitBox").damage = attack.damage
	projectile.position = position + attack.projectile_offset * direction
	projectile.direction = Vector2.RIGHT * direction
	projectile._set_exception(self)
	get_tree().current_scene.add_child(projectile)
	
	
	frame_number = frames.get_frame_count(attack.post_animation_name)
	anim_speed = frame_number / attack.post_attack_duration
	frames.set_animation_speed(attack.post_animation_name, anim_speed)
	sprite.play(attack.post_animation_name)
	await get_tree().create_timer(attack.post_attack_duration).timeout
	
	is_walking = 1
	sprite.play("walk")
	is_attacking = false	

	
func _start_dash():
	if !dashing:
		dashing = true
		$DashingTimer.start()

func _spawn_healthbar():
	healthbar = healthbar_object.instantiate()
	get_tree().get_root().add_child(healthbar)
	healthbar.setup(self)


func _on_health_depleted() -> void:
	healthbar._deplete()
	queue_free()
	
func _on_dashing_timer_timeout() -> void:
	dashing = false

	
func _on_hurt_box_received_damage(_damage: int, attacker_pos: Vector2) -> void:
	flash_animation.play("flash")
	apply_knockback(attacker_pos)
	healthbar.update()
	_stun()

func _on_attack_cooldown_timeout() -> void:
	attack_allowed = true

func apply_knockback(attacker_pos: Vector2) -> void:
	# Knockback: Immer weg vom Gegner!
	var knock_dir = sign(global_position.x - attacker_pos.x)
	if knock_dir == 0:
		knock_dir = 1

	velocity.x = knock_dir * 200.0
	velocity.y = -80.0

	knockback_timer = knockback_length
