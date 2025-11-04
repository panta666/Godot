class_name HurtBox
extends Area2D

signal received_damage(damage: int)

@export var health: Health

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
	if area is HitBox:
		var hitbox := area as HitBox
		health.health -= hitbox.damage
		received_damage.emit(hitbox.damage)
