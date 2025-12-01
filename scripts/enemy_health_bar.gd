extends Node2D

@onready var health_bar = $TextureProgressBar

var health

var enemy

func setup(_enemy: Enemy):
	enemy = _enemy
	health = enemy.get_node("Health")

func _ready():
	set_process(true)
	if health != null:
		update()

func update():
	if health != null:
		health_bar.value = health.get_health() * 100 / health.get_max_health()
	
func _process(_delta: float) -> void:
	if enemy != null:
		global_position = enemy.global_position + enemy.HEALTH_BAR_POSITION
		
func _deplete():
	queue_free()
