extends CharacterBody2D


const SPEED = 50.0

var direction = 1

var is_walking = 1

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
		sprite.play("walk")
		if !ray_cast_down_right.is_colliding() or ray_cast_right.is_colliding():
			direction *= -1
			scale.x *= -1
			$RayCastRight.target_position.x *= -1
		else:
			if _is_player_in_sight():
				track_player(player.position)
			else:
				is_walking = 1
				sprite.play("walk")
				if player != null:
					var bodies = tracking_box.get_overlapping_bodies()
					if player in bodies:
						track_player(player.position)
						is_walking = 0
						sprite.stop()
					else:
						player = null
			
			
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
	
func _is_player_in_vicinity() -> bool:
	return true
	
func track_player(player_position: Vector2):
	sprite.play("walk")
	is_walking =1
	var dx = abs(player_position.x - position.x)
	#print(dx)
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
		sprite.stop()

func _attack():
	is_walking = 0

func _on_health_depleted() -> void:
	queue_free()
