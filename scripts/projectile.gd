extends Area2D


@export var speed: float = 400.0       # Pixels per second
@export var direction: Vector2 = Vector2.RIGHT  # Direction the projectile moves


func _physics_process(delta):
	# Move the projectile
	position += direction.normalized() * speed * delta



func _on_body_entered(_body: Node2D) -> void:
	queue_free()
