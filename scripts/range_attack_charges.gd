extends TextureButton

@onready var charge_bar: TextureProgressBar = $ChargeBar
@onready var current_charges: Label = $CurrentCharges

var max_value := 100.0  # ProgressBar max = 100

#Verschiedene Angriffe Preloaden
const ATTACK_ICONS  ={
	"oop_capsule": preload("res://assets/range_attacks/oop_capsule/oop_capsule.png"),
	"fireball": preload("res://assets/fire ball/fire ball 1.png")
}


func _ready():
	charge_bar.min_value = 0
	charge_bar.max_value = max_value
	charge_bar.value = charge_bar.min_value  # Start: voll
	
	set_attack_texture()

func update_charge_text(current: int, max_charges: int):
	current_charges.text = "%d / %d" % [current, max_charges]

# progress zwischen 0.0 → 1.0 umgerechnet auf 0 → 100
func update_recharge_progress(progress: float):
	charge_bar.value = max_value - progress * max_value

func set_attack_texture():
	var current_scene = get_tree().current_scene
	var scene_name = current_scene.name
	print(scene_name)
	if "oop" in scene_name:
		texture_normal = ATTACK_ICONS["oop_capsule"]
	elif "medg" in scene_name:
		texture_normal = ATTACK_ICONS["fireball"]
	else:
		texture_normal = ATTACK_ICONS["fireball"]
