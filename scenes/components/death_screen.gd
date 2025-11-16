extends CanvasLayer

@onready var anim = $AnimationPlayer

func play_screen() -> void:
	anim.play("show")
	await anim.animation_finished
