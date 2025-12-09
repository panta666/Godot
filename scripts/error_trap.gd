extends Node2D

@export var speed = 160.0
var current_speed = 0.0

#Fehlermeldung fällt runter
func _physics_process(delta: float) -> void:
	position.y += current_speed * delta

#Level wird bei Treffer neu gestartet
func _on_hitbox_area_entered(_area: Area2D) -> void:
	#get_tree().reload_current_scene()
	print("trap")

#Erkennen des Spielers in der Nähe und Auslösen der Falle
func _on_player_detect_area_entered(_area: Area2D) -> void:
	$Label.visible = true
	fall()

#Falle wird ausgelöst
func fall():
	current_speed = speed
	await get_tree().create_timer(5).timeout
	queue_free()
