extends CenterContainer

# --- Options-UI ---
@onready var master_volume: HSlider = $VBoxContainer/MasterVolume
@onready var check_box: CheckBox = $VBoxContainer/CheckBox
@onready var music_volume: HSlider = $VBoxContainer/MusicVolume
@onready var sfx_volume: HSlider = $VBoxContainer/SFXVolume


# --- Soundbus-IDs ---
const MASTER_BUS := 0
const MUSIC_BUS := 1
const SFX_BUS := 2


# --------------------------
# Audio
func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MASTER_BUS, value)

func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS, value)

func _on_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(MASTER_BUS, toggled_on)
	SaveManager.update_is_muted(toggled_on)


func _on_master_volume_drag_ended(_value_changed: bool) -> void:
	SaveManager.update_bus_volume(MASTER_BUS, master_volume.value)


func _on_music_volume_drag_ended(_value_changed: bool) -> void:
	SaveManager.update_bus_volume(MUSIC_BUS, music_volume.value)

func _on_sfx_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(SFX_BUS, value)


func _on_sfx_volume_drag_ended(_value_changed: bool) -> void:
	SaveManager.update_bus_volume(SFX_BUS, sfx_volume.value)
