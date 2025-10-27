extends CharacterBody2D


const SPEED = 50.0

var direction = 1

@onready var ray_cast_down_right = $RaycastDownRight

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft

@onready var sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor():
		sprite.play("walk")
		if !ray_cast_down_right.is_colliding():
			direction *= -1
			scale.x *= -1
			$RayCastRight.target_position.x *= -1
			
		velocity.x = direction * SPEED
		
		

	move_and_slide()
