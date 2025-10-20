extends Control

signal closed

var MASTER_BUS := 0
var MUSIC_BUS := 1
var SFX_BUS := 2

func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MASTER_BUS, value)

func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS, value)

func _on_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)



func _on_back_pressed() -> void:
	emit_signal("closed")
	queue_free()
