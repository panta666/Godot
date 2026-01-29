extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.playMusic(MusicManager.MusicType.MATHE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	



func _on_fall_damage_3_body_entered(body: Node2D) -> void:
	if not body.has_method("player"):
		return

	# Spieler sofort teleportieren zu festen Koordinaten
	# Deferred, damit Physics-Signal nicht blockiert wird
	body.call_deferred("set_global_position", Vector2(930, -200))


func _on_fall_damage_4_body_entered(body: Node2D) -> void:
	if not body.has_method("player"):
		return

	# Spieler sofort teleportieren zu festen Koordinaten
	# Deferred, damit Physics-Signal nicht blockiert wird
	body.call_deferred("set_global_position", Vector2(1850, -300))
