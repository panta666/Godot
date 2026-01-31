extends Area2D
class_name Projectile

@export var speed: float = 400.0
@export var apply_gravity := false
@export var _gravity := gravity

var velocity: Vector2
var exception: Node2D

func _ready() -> void:
	gravity = _gravity

func set_direction(dir: Vector2):
	velocity = dir.normalized() * speed

func _physics_process(delta):
	# Apply gravity
	if apply_gravity:
		velocity.y += gravity * delta

	# Move projectile
	position += velocity * delta

func _set_exception(_exception: Node2D):
	exception = _exception

	
func _set_gravity(_gravity: float):
	gravity = _gravity

func _on_body_entered(body: Node2D) -> void:
	if exception == null or body != exception:
		queue_free()
		
