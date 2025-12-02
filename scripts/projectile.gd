extends Area2D


@export var speed: float = 400.0       
@export var direction: Vector2 = Vector2.RIGHT  
var exception: Node2D

func _physics_process(delta):
	# Move the projectile
	position += direction.normalized() * speed * delta

func _set_exception(_exception: Node2D):
	exception = _exception


func _on_body_entered(body: Node2D) -> void:
	if exception != null:
		if body != exception:
			queue_free()
	else:
		queue_free()
