extends Area2D


@onready var pickup_sound_player: AudioStreamPlayer2D = $PickupSoundPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var classroom = ""


func _on_body_entered(_body: Node2D) -> void:
	if classroom == "":
		printerr("Nicht angegeben in welchem Classroom, coin wird nicht aufgesammelt!")
	else:
		collect_coin()

func collect_coin():
	"""
	Kollision sofort deaktivieren.
	set_deferred muss benutzt werden, da wir uns mitten in einem Physik-Callback
	befinden. Direkte Änderung würde Fehler werfen.
	"""
	collision_shape_2d.set_deferred("disabled", true)
	
	# Alle visuals aus.
	hide()
	GlobalScript.add_coin_for_classroom(classroom)
	pickup_sound_player.play()
	# Warte bis der Sound vorbei ist, da sonst kein Sound kommt.
	await pickup_sound_player.finished
	
	queue_free()
