class_name HurtBox
extends Area2D

signal received_damage(damage: int, attacker_position: Vector2)

@export var health: Health

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
	if area is HitBox:
		var hitbox := area as HitBox

		# Schaden anwenden
		health.health -= hitbox.damage

		# Angreifer ermitteln (Elternknoten der HitBox)
		var attacker := hitbox.get_parent()
		var attacker_pos: Vector2 = attacker.global_position

		# Signal senden
		received_damage.emit(hitbox.damage, attacker_pos)
