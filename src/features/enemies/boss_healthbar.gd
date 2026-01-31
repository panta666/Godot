extends CanvasLayer

@onready var health_bar = $Control/ProgressBar

@onready var health_bar2 = $Control/ProgressBar2

@onready var health_bar3 = $Control/ProgressBar3

var health_nodes = []

var boss

# Alle Health-Komponenten setzen
func setup(_boss: Enemy):
	boss = _boss
	for node in boss.get_tree().get_nodes_in_group("health"):
		health_nodes.append(node)
		
	print(health_nodes)
	update()

# Alle drei Hurtbox-Werte setzen
func update():
	for node in health_nodes:
		if node == null:
			return
	health_bar.value = health_nodes[0].get_health() * 100 / health_nodes[0].get_max_health()
	health_bar2.value = health_nodes[1].get_health() * 100 / health_nodes[1].get_max_health()
	health_bar3.value = health_nodes[2].get_health() * 100 / health_nodes[2].get_max_health()

		
func _deplete():
	queue_free()
