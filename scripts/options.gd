extends Control

# Signal das ausgesendet werden kann um das Menü zu schließen.
signal closed

# Die Soundbusses.
var MASTER_BUS := 0
var MUSIC_BUS := 1
var SFX_BUS := 2


# Mastervolume Slider der den Bus Master anpasst.
func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MASTER_BUS, value)

# Mastervolume Slider der den Bus Musik anpasst.
func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS, value)

# Checkbox um das Spiel zu stumm und laut zu stellen.
func _on_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)

# Signal closed wird gefeuert um listenern zu zeigen das die Szene geschlossen wird.
func _on_back_pressed() -> void:
	emit_signal("closed")
	queue_free()
