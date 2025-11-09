extends Control

# Signal das ausgesendet werden kann um das Menü zu schließen.
signal closed

# Die Soundbusses.
var MASTER_BUS := 0
var MUSIC_BUS := 1
var SFX_BUS := 2

# UI Elemente
@onready var master_volume: HSlider = $MarginContainer/CenterContainer/VBoxContainer/MasterVolume
@onready var check_box: CheckBox = $MarginContainer/CenterContainer/VBoxContainer/CheckBox
@onready var music_volume: HSlider = $MarginContainer/CenterContainer/VBoxContainer/MusicVolume



# In der ready Funktion werden die gespeicherten Soundeinstellungen geladen damit sie wieder richtig angezeigt werden.
func _ready() -> void:
	var audio_settings := SaveManager.get_audio_settings()
	


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
