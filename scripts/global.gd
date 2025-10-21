extends Node

var current_scene = 'realworld_classroom_one'
var transition_scene  = false

#Classroom_1 Türlocation
var player_exit_door_posX = 568
var player_exit_door_posY = 374

#Spieler Startposition im Spiel
var player_start_posX = 504
var player_start_posY = 340

var game_first_loading = true
	
func finish_change_scene():
	transition_scene = false
	if current_scene == 'realworld_classroom_one':
		current_scene = 'realworld_hall'
	else:
		current_scene = 'realworld_classroom_one'
