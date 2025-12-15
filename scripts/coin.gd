extends Area2D


@onready var pickup_sound_player: AudioStreamPlayer2D = $PickupSoundPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_dreamworld: CharacterBody2D = %Player_Dreamworld
@onready var player_dreamworld_tutorial: CharacterBody2D = %Player_Dreamworld

@export var classroom = ""


func _ready() -> void:
	if SaveManager.coin_is_collected(classroom, self.name):
		disable_coin()

func _on_body_entered(_body: Node2D) -> void:
	if classroom == "":
		printerr("Nicht angegeben in welchem Classroom, coin wird nicht aufgesammelt!")
	elif _body == player_dreamworld || _body == player_dreamworld_tutorial:
		collect_coin()

func disable_coin():
	collision_shape_2d.set_deferred("disabled", true)
	
	# Alle visuals aus.
	hide()

func collect_coin():
	"""
	Kollision sofort deaktivieren.
	set_deferred muss benutzt werden, da wir uns mitten in einem Physik-Callback
	befinden. Direkte Änderung würde Fehler werfen.
	"""
	disable_coin()
	GlobalScript.add_coin_for_classroom(classroom, self.name)
	pickup_sound_player.play()
	# Warte bis der Sound vorbei ist, da sonst kein Sound kommt.
	await pickup_sound_player.finished
	
	queue_free()
