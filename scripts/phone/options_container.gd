extends CenterContainer

# --- Options-UI ---
@onready var master_volume: HSlider = $VBoxContainer/MaVContainer/MasterVolume
@onready var mv_mute: CheckBox = $VBoxContainer/MaVContainer/MaVMuteCheckBox
@onready var music_volume: HSlider = $VBoxContainer/MuVContainer/MusicVolume
@onready var mu_mute: CheckBox = $VBoxContainer/MuVContainer/MuVMuteCheckBox
@onready var sv_mute: CheckBox = $VBoxContainer/SVContainer/SVMuteCheckBox
@onready var sfx_volume: HSlider = $VBoxContainer/SVContainer/SFXVolume


# --- Soundbus-IDs ---
const MASTER_BUS := 0
const MUSIC_BUS := 1
const SFX_BUS := 2

func _ready() -> void:
	var audio_settings := SaveManager.get_audio_settings()
	master_volume.value = audio_settings["Master"]
	music_volume.value = audio_settings["Music"]
	sfx_volume.value = audio_settings["SFX"]
	mv_mute.button_pressed = audio_settings["is_muted"]


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


func _on_sv_mute_check_box_3_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(SFX_BUS, toggled_on)


func _on_mu_v_mute_check_box_2_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(MUSIC_BUS, toggled_on)
