extends CharacterBody2D

@export var attacks: Array[Attack] = []

@onready var health = $Health.health

const SPEED = 50.0

const DASH_SPEED = 300.0

var direction = 1

var is_walking = 1

var dashing = false

var dash_allowed = true

var is_attacking = false

var player: Node2D = null

@onready var ray_cast_down_right = $RaycastDownRight

@onready var ray_cast_right = $RayCastRight

@onready var sprite = $AnimatedSprite2D

@onready var back_vision = $Vision_Back

@onready var front_vision = $Vision_Front

@onready var tracking_box = $Tracking_Box

func _physics_process(delta: float) -> void:
	print(health)
	# Add the gravity.
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor():
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
				if !is_attacking:
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
	
func _pause():
	is_walking = 0
	velocity.x = 0
	sprite.pause()

	
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

func _start_attack():
	print("choose_attack")
	var r  = randi_range(0, attacks.size() - 1)
	_attack(attacks[r])



func _attack(attack: Attack):
	is_attacking = true
	var hitbox = $HitBox/CollisionShape2D
	#hitbox.position = attack.hitbox_offset

	is_walking = 0
	sprite.pause()
	print("windup")
	await get_tree().create_timer(attack.pre_attack_duration).timeout
	print("attack")
	is_walking = 1
	sprite.play("walk")
	var attack_duration = attack.attack_duration

	match attack.movement:
		attack.movement_type.DASH:
			_start_dash()
			attack_duration = $DashingTimer.wait_time
		attack.movement_type.NONE:
			is_walking = 0
			sprite.pause()

	hitbox.disabled = false

	await get_tree().create_timer(attack.attack_duration).timeout

	hitbox.disabled = true

	print("cooldown")
	is_walking = 0
	sprite.pause()
	await get_tree().create_timer(attack.attack_duration).timeout
	is_walking = 1
	sprite.play("walk")
	is_attacking = false


func received_damage(damage: int) -> void:
	if dashing:
		return

	print("Enemy takes", damage, "damage!")
	print("Enemy HP: ", health.get_health())

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

