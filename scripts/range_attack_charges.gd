extends TextureButton

@onready var charge_bar: TextureProgressBar = $ChargeBar
@onready var current_charges: Label = $CurrentCharges

var max_value := 100.0  # ProgressBar max = 100

func _ready():
	charge_bar.min_value = 0
	charge_bar.max_value = max_value
	charge_bar.value = charge_bar.min_value  # Start: voll

func update_charge_text(current: int, max_charges: int):
	current_charges.text = "%d / %d" % [current, max_charges]

# progress zwischen 0.0 → 1.0 umgerechnet auf 0 → 100
func update_recharge_progress(progress: float):
	charge_bar.value = max_value - progress * max_value
