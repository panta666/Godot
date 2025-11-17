extends CharacterBody2D

@export var attacks: Array[Attack] = []

@export var range_attacks: Array[Range_Attack] = []

var projectile_object = preload("res://scenes/Enemies/Projectile.tscn")

@onready var health = $Health.health

const SPEED = 50.0

const STUN_TIME = 0.3

const DASH_SPEED = 300.0

const RANGE = 250

var direction = 1

var is_walking = 1

var dashing = false

var stunned = false

var dash_allowed = true

var is_attacking = false

var attack_allowed = true

var player: Node2D = null

@onready var ray_cast_down_right = $RaycastDownRight

@onready var ray_cast_right = $RayCastRight

@onready var sprite = $AnimatedSprite2D

@onready var back_vision = $Vision_Back

@onready var front_vision = $Vision_Front

@onready var tracking_box = $Tracking_Box


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
						_start_attack(RANGE)
					if !dashing:
						track_player(player.position)
				else:
					#if !is_attacking:
					is_walking = 1
					sprite.play("walk")
					if player != null:
						var bodies = tracking_box.get_overlapping_bodies()
						if player in bodies:
							if !dashing:
								track_player(player.position)
								is_walking = 0
								sprite.pause()
						else:
							player = null
				
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
	await get_tree().create_timer(STUN_TIME).timeout
	stunned = false


	
func track_player(player_position: Vector2):
	if !is_attacking:
		sprite.play("walk")
		is_walking =1
	var dx = abs(player_position.x - position.x)
	if dx > 15:
		if player_position.x > position.x:
			direction = 1
			transform.x = Vector2(1.0*scale.x, 0.0)
		else:
			direction = -1
			transform.x = Vector2(-1.0*scale.x, 0.0)
		
		ray_cast_right.target_position.x = abs(ray_cast_right.target_position.x) * direction
	else:
		is_walking = 0
		sprite.pause()
		
func _start_attack(attack_range: float):
		if player != null:
			if range_attacks.is_empty():
				var r  = randi_range(0, attacks.size() - 1)	
				_attack(attacks[r])
			else:
				if player.global_position.distance_to(global_position) > attack_range:
					var r  = randi_range(0, attacks.size() - 1)	
					_range_attack(range_attacks[r])
				else:
					var r  = randi_range(0, attacks.size() - 1)	
					_attack(attacks[r])
		
		
func _attack(attack: Attack):
	is_attacking = true
	var hitbox = $HitBox/CollisionShape2D
	hitbox.position = attack.hitbox_offset
	var shape := hitbox.shape as RectangleShape2D
	shape.extents = attack.hitbox_size
	$HitBox.damage = attack.damage
	
	print(attack.hitbox_offset)
	
	is_walking = 0
	sprite.pause()
	await get_tree().create_timer(attack.pre_attack_duration).timeout
	is_walking = 1
	sprite.play("walk")
	var attack_duration = attack.hitbox_duration
	
	match attack.movement:
		attack.movement_type.DASH:
			_start_dash()
			attack_duration = $DashingTimer.wait_time
		attack.movement_type.NONE:
			is_walking = 0
			sprite.pause()
	
	hitbox.disabled = false
	
	await get_tree().create_timer(attack_duration).timeout
	
	hitbox.disabled = true
	
	is_walking = 0
	sprite.pause()
	await get_tree().create_timer(attack.post_attack_duration).timeout
	is_walking = 1
	sprite.play("walk")
	is_attacking = false
	

func _range_attack(attack: Range_Attack):
	is_attacking = true
	
	is_walking = 0
	sprite.pause()
	await get_tree().create_timer(attack.pre_attack_duration).timeout

	var projectile = projectile_object.instantiate()
	projectile.get_node("HitBox").damage = 10
	projectile.position = position + attack.projectile_offset * direction
	projectile.direction = Vector2.RIGHT * direction
	get_tree().current_scene.add_child(projectile)
	
	await get_tree().create_timer(attack.post_attack_duration).timeout
	is_walking = 1
	sprite.play("walk")
	is_attacking = false	

	
func _start_dash():
	if dash_allowed and !dashing:
		dashing = true
		$DashingTimer.start()


func _on_health_depleted() -> void:
	queue_free()
	
func _on_dashing_timer_timeout() -> void:
	dashing = false
	$DashingCoolDownTimer.start()
	dash_allowed = false


func _on_dashing_cool_down_timer_timeout() -> void:
	dash_allowed = true
	
func _on_hurt_box_received_damage(damage: int) -> void:
	print("stunned")
	_stun()

func _on_attack_cooldown_timeout() -> void:
	attack_allowed = true
