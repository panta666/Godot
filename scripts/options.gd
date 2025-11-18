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
@onready var sfx_volume: HSlider = $MarginContainer/CenterContainer/VBoxContainer/SFXVolume




# In der ready Funktion werden die gespeicherten Soundeinstellungen geladen damit sie wieder richtig angezeigt werden.
func _ready() -> void:
	var audio_settings := SaveManager.get_audio_settings()
	master_volume.value = audio_settings["Master"]
	music_volume.value = audio_settings["Music"]
	sfx_volume.value = audio_settings["SFX"]
	check_box.button_pressed = audio_settings["is_muted"]


# Mastervolume Slider der den Bus Master anpasst.
func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MASTER_BUS, value)

# Speichert den neuen Wert
func _on_master_volume_drag_ended(_value_changed: bool) -> void:
	SaveManager.update_bus_volume(MASTER_BUS, master_volume.value)

# Mastervolume Slider der den Bus Musik anpasst.
func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS, value)

# Speichert den neuen Wert
func _on_music_volume_drag_ended(_value_changed: bool) -> void:
	SaveManager.update_bus_volume(MUSIC_BUS, music_volume.value)

# Checkbox um das Spiel zu stumm und laut zu stellen.
func _on_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)
	SaveManager.update_is_muted(toggled_on)

# Signal closed wird gefeuert um listenern zu zeigen das die Szene geschlossen wird.
func _on_back_pressed() -> void:
	emit_signal("closed")
	queue_free()


func _on_sfx_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(SFX_BUS, value)


func _on_sfx_volume_drag_ended(_value_changed: bool) -> void:
	SaveManager.update_bus_volume(SFX_BUS, sfx_volume.value)
