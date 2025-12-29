extends TextureButton

@onready var charge_bar: TextureProgressBar = $ChargeBar
@onready var current_charges: Label = $CurrentCharges

var max_value := 100.0  # ProgressBar max = 100

#Verschiedene Angriffe Preloaden
const HEAL_ICONS  ={
	"basic_heal_icon": preload("res://assets/heal_ability/heal_ability.png"),
}


func _ready():
	charge_bar.min_value = 0
	charge_bar.max_value = max_value
	charge_bar.value = charge_bar.min_value
	
	set_healing_texture()

func update_charge_text(current: int, max_charges: int):
	current_charges.text = "%d / %d" % [current, max_charges]

# progress zwischen 0.0 → 1.0 umgerechnet auf 0 → 100
func update_recharge_progress(progress: float):
	charge_bar.value = max_value - progress * max_value

func set_healing_texture():
	texture_normal = HEAL_ICONS["basic_heal_icon"]
	var current_scene = get_tree().current_scene
	var scene_name = current_scene.get_name().to_lower()
	if "oop" in scene_name.to_lower():
		texture_normal = HEAL_ICONS["basic_heal_icon"]
	elif "math" in scene_name.to_lower():
		texture_normal = HEAL_ICONS["basic_heal_icon"]
	else:
		texture_normal = HEAL_ICONS["basic_heal_icon"]
