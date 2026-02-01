extends CanvasLayer

# -------------------------------------------------
# Onready-Referenzen
# -------------------------------------------------
@onready var control: Control = $Control
@onready var menu_container: VBoxContainer = $Control/MenuContainer
@onready var options_container: Control = $Control/OptionsContainer
@onready var quit_button: Button = $Control/MenuContainer/MenuOptions/Quit
@onready var phone: Sprite2D = $Control/Phone
@onready var phone_background: AnimatedSprite2D = $Control/PhoneScreenContainer/Background
@onready var back: Area2D = $Control/Phone/PowerArea
@onready var blinking: Node2D = $Control/Blinking

# -------------------------------------------------
# State
# -------------------------------------------------
var is_open := false
var is_transitioning := false

# -------------------------------------------------
# Ready
# -------------------------------------------------
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	_hide_all()
	back.input_event.connect(_on_back_pressed)

# -------------------------------------------------
# ESC Handling
# -------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("esc_menu"):
		return

	var player := GlobalScript.player
	var player_dw := get_tree().current_scene.get_node_or_null("Player_Dreamworld")
	var current = get_tree().current_scene
	
	print("[ESC] Scene:", current.name)
	print("[ESC] Realworld Player:", player, "| valid:", is_instance_valid(player))
	print("[ESC] Dreamworld Player:", player_dw, "| valid:", is_instance_valid(player_dw))

	if current == null:
		print("[ESC] Kein current_scene")
		return
	print("[ESC] Scene:", current.name)

	if current.name == "MainMenu":
		print("[ESC] ESC blockiert: MainMenu")
		return
		
	if current.name == "TrainScene":
		print("[ESC] ESC blockiert: TrainScene")
		return

	if GlobalScript.transition_scene:
		print("[ESC] ESC blockiert: Transition läuft")
		return

	# Dreamworld: player_dw vorhanden - nur Pause, Realworld-check überspringen
	if player_dw and is_instance_valid(player_dw):
		print("[ESC] Dreamworld Player vorhanden")
		if is_open:
			print("[ESC] Menü schließen")
			close_menu()
		else:
			print("[ESC] Menü öffnen")
			open_menu()
		return  

	# Realworld: nur blockieren, wenn Realworld-Player busy ist
	if player and is_instance_valid(player):
		print("[ESC] Realworld Player vorhanden")
		if player.is_busy:
			print("[ESC] ESC blockiert: Player is_busy")
			return
		if is_transitioning:
			print("[ESC] ESC blockiert: Menu is_transitioning")
			return

	if is_open:
		print("[ESC] Menü schließen")
		close_menu()
	else:
		print("[ESC] Menü öffnen")
		open_menu()
# -------------------------------------------------
# Öffnen
# -------------------------------------------------
func open_menu() -> void:
	is_open = true
	visible = true
	var current = get_tree().current_scene

	var player := GlobalScript.player
	var player_dw := get_tree().current_scene.get_node_or_null("Player_Dreamworld")

	# Dreamworld
	if player_dw and is_instance_valid(player_dw):
		get_tree().paused = true
		# Button-Text nur ändern, wenn es nicht Tutorial ist
		if current.name != "dreamworld_tutorial":
			quit_button.text = "Wake Up"
		else:
			quit_button.text = "Quit"
	else:
		quit_button.text = "Quit"

	# Realworld - Handy-Animation
	if player and is_instance_valid(player):
		is_transitioning = true
		player.can_move = false
		player.can_interact = false
		player.open_mobile(Callable(self, "_on_open_mobile_finished"))

	menu_container.visible = true
	options_container.visible = false
	phone.visible = true
	phone_background.visible = true
	blinking.visible = true

# -------------------------------------------------
func _on_open_mobile_finished() -> void:
	is_transitioning = false

# -------------------------------------------------
# Schließen
# -------------------------------------------------
func close_menu() -> void:
	if is_transitioning:
		return

	is_open = false

	var player := GlobalScript.player
	var player_dw := get_tree().current_scene.get_node_or_null("Player_Dreamworld")

	# Dreamworld
	if player_dw and is_instance_valid(player_dw):
		get_tree().paused = false
		_hide_all()
		return

	# Realworld
	if player and is_instance_valid(player):
		is_transitioning = true
		player.close_mobile(Callable(self, "_on_close_mobile_finished"))
	else:
		_hide_all()

# -------------------------------------------------
func _on_close_mobile_finished() -> void:
	var player := GlobalScript.player
	if player and is_instance_valid(player):
		player.can_move = true
		player.can_interact = true

	is_transitioning = false
	_hide_all()

# -------------------------------------------------
# Buttons
# -------------------------------------------------
func _on_continue_pressed() -> void:
	close_menu()

func _on_options_pressed() -> void:
	menu_container.visible = false
	options_container.visible = true

func _on_quit_pressed() -> void:
	var player_dw := get_tree().current_scene.get_node_or_null("Player_Dreamworld")
	var current = get_tree().current_scene
	GlobalScript.reset_coins()

	# Pause immer aufheben, wenn Traumwelt
	if player_dw and is_instance_valid(player_dw):
		get_tree().paused = false

		# Schließe Menü
		close_menu()

		# Szene wechseln, außer Tutorial
		if current.name != "dreamworld_tutorial":
			if GlobalScript.previous_scene != "":
				GlobalScript.change_scene(GlobalScript.previous_scene)
			else:
				GlobalScript.change_scene("realworld_hall")
		# Tutorial - einfach quit
		else:
			get_tree().quit()
	else:
		get_tree().quit()

# -------------------------------------------------
# Back Button (Phone)
# -------------------------------------------------
func _on_back_pressed(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		menu_container.visible = true
		options_container.visible = false

# -------------------------------------------------
# Helpers
# -------------------------------------------------
func _hide_all() -> void:
	menu_container.visible = false
	options_container.visible = false
	phone.visible = false
	phone_background.visible = false
	blinking.visible = false
	visible = false
