extends CharacterBody2D
class_name PlayerRealworld

const SPEED = 120.0
const SCALE_FACTOR = 1.5

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D

var facing_direction: String = "down"
var sitting: bool = false

# --- Bewegung & Interaktion Flags ---
var can_move: bool = true
var can_interact: bool = true
var is_busy: bool = false

# --- Shop Flags ---
var is_shopping: bool = false

# --- Handy Callback ---
var _mobile_callback: Callable

# Sounds für random footsteps
const FOOTSTEP_SOUNDS = [
	preload("res://assets/sfx/kenney_impact-sounds/Audio/footstep_wood_001.ogg"),
	preload("res://assets/sfx/kenney_impact-sounds/Audio/footstep_wood_002.ogg"),
	preload("res://assets/sfx/kenney_impact-sounds/Audio/footstep_wood_003.ogg"),
	preload("res://assets/sfx/kenney_impact-sounds/Audio/footstep_wood_004.ogg")
]
# Theoretisch kann jede animation einen anderen play timer haben.
const FOOTSTEP_FRAMES = {"walk_side":[1,4], "walk_up":[1,4], "walk_down":[1,4]}

@onready var footstep_player = $FootstepPlayer

func _ready() -> void:
	scale = Vector2(SCALE_FACTOR, SCALE_FACTOR)

	if not Engine.is_editor_hint():
		GlobalScript.player = self

	if get_tree().current_scene and get_tree().current_scene.name == "MainMenu":
		disable_player()
	else:
		enable_player()
		if camera_2d:
			camera_2d.make_current()

	set_process(true)
	set_physics_process(true)
	
# --------------------------
# Bewegung & Animation
# --------------------------
func _physics_process(_delta: float) -> void:
	if not can_move:
		return

	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	velocity = input_vector * SPEED
	move_and_slide()

	if input_vector == Vector2.ZERO:
		match facing_direction:
			"up": animated_sprite_2d.play("idle_up")
			"down": animated_sprite_2d.play("idle_down")
			"side": animated_sprite_2d.play("idle_side")
	else:
		if abs(input_vector.x) > abs(input_vector.y):
			animated_sprite_2d.play("walk_side")
			animated_sprite_2d.flip_h = input_vector.x < 0
			facing_direction = "side"
		elif input_vector.y < 0:
			animated_sprite_2d.play("walk_up")
			facing_direction = "up"
		elif input_vector.y > 0:
			animated_sprite_2d.play("walk_down")
			facing_direction = "down"

# --------------------------
# Handy (ESC) Animationen
# --------------------------
func open_mobile(callback: Callable) -> void:
	print("[PLAYER] open_mobile() gestartet")
	_mobile_callback = callback
	animated_sprite_2d.play("mobile_hand")

	if animated_sprite_2d.animation_finished.is_connected(_on_mobile_hand_finished):
		animated_sprite_2d.animation_finished.disconnect(_on_mobile_hand_finished)
	animated_sprite_2d.animation_finished.connect(_on_mobile_hand_finished)

func _on_mobile_hand_finished() -> void:
	print("[PLAYER] _on_mobile_hand_finished() aufgerufen | Animation=", animated_sprite_2d.animation)
	if animated_sprite_2d.animation == "mobile_hand":
		if animated_sprite_2d.animation_finished.is_connected(_on_mobile_hand_finished):
			animated_sprite_2d.animation_finished.disconnect(_on_mobile_hand_finished)
		animated_sprite_2d.play("mobile_idle")

		if _mobile_callback != null and _mobile_callback.is_valid():
			print("[PLAYER] open_mobile Callback wird ausgeführt")
			_mobile_callback.call()
			_mobile_callback = Callable()  # Reset

func close_mobile(callback: Callable = Callable()) -> void:
	print("[PLAYER] close_mobile() gestartet")
	_mobile_callback = callback
	animated_sprite_2d.play("mobile_pocket")

	# Alte Verbindung trennen, falls vorhanden
	if animated_sprite_2d.animation_finished.is_connected(_on_mobile_pocket_finished):
		animated_sprite_2d.animation_finished.disconnect(_on_mobile_pocket_finished)

	# Verbindung neu setzen
	animated_sprite_2d.animation_finished.connect(_on_mobile_pocket_finished)

func _on_mobile_pocket_finished() -> void:
	print("[PLAYER] _on_mobile_pocket_finished() aufgerufen | Animation=", animated_sprite_2d.animation)
	if animated_sprite_2d.animation == "mobile_pocket":
		if animated_sprite_2d.animation_finished.is_connected(_on_mobile_pocket_finished):
			animated_sprite_2d.animation_finished.disconnect(_on_mobile_pocket_finished)
		animated_sprite_2d.play("idle_down")

	if _mobile_callback != null and _mobile_callback.is_valid():
		print("[PLAYER] close_mobile Callback wird ausgeführt")
		_mobile_callback.call()
		_mobile_callback = Callable()  # Reset

# --------------------------
# Hilfsfunktionen
# --------------------------
func set_facing_direction(dir: String) -> void:
	facing_direction = dir

func get_facing_direction() -> String:
	return facing_direction
	
func player():
	pass

# --------------------------
# NPC-Richtung
# --------------------------
func _face_npc(npc_position: Vector2) -> void:
	var dir = npc_position - global_position
	if abs(dir.x) > abs(dir.y):
		facing_direction = "side"
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play("idle_side")
	else:
		if dir.y > 0:
			facing_direction = "down"
			animated_sprite_2d.play("idle_down")
		else:
			facing_direction = "up"
			animated_sprite_2d.play("idle_up")

func play_footstep_sound():
	# Verhindert, dass Sounds sich überlagern, wenn die Funktion
	# schnell hintereinander aufgerufen wird
	if footstep_player.is_playing():
		return

	# Wählt einen zufälligen Sound aus der Liste
	footstep_player.stream = FOOTSTEP_SOUNDS.pick_random()

	# Variiert die Tonhöhe leicht (zwischen 90% und 110%)
	# Dies ist der wichtigste Trick, damit es nicht robotisch klingt!
	footstep_player.pitch_scale = randf_range(0.9, 1.1)

	# Spielt den Sound ab
	footstep_player.play()

# --- Sitz-Logik ---
func sit_on_chair(target_pos: Vector2) -> void:
	global_position = target_pos
	sitting = true
	can_move = false
	can_interact = false
	is_busy = true
	velocity = Vector2.ZERO
	animated_sprite_2d.flip_h = false
	animated_sprite_2d.play("sit")

func stand_up(target_pos: Vector2) -> void:
	sitting = false
	can_move = true
	can_interact = true
	is_busy = false
	global_position = target_pos
	animated_sprite_2d.play("idle_down")
	
	
# --------------------------
# Shop-Logik
# --------------------------
func open_shop() -> void:
	is_shopping = true
	can_move = false
	can_interact = false
	is_busy = true
	animated_sprite_2d.play("idle_up")

func close_shop() -> void:
	is_shopping = false
	can_move = true
	can_interact = true
	is_busy = false
	animated_sprite_2d.play("idle_down")
# --------------------------
# MainMenu Aktivierung/Deaktivierung
# --------------------------
func disable_player() -> void:
	can_move = false
	can_interact = false
	set_process(false)
	set_physics_process(false)
	animated_sprite_2d.stop()
	visible = false

func enable_player() -> void:
	can_move = true
	can_interact = true
	set_process(true)
	set_physics_process(true)
	visible = true


func _on_animated_sprite_2d_frame_changed() -> void:
	if (animated_sprite_2d.animation == "walk_down"
	|| animated_sprite_2d.animation == "walk_side"
	||animated_sprite_2d.animation == "walk_up"):
		if animated_sprite_2d.frame in FOOTSTEP_FRAMES[animated_sprite_2d.animation]:
			play_footstep_sound()

func cutscene_start() -> void:
	print("[PlayerRealworld] cutscene_start()")
	can_move = false
	can_interact = false
	is_busy = true
	velocity = Vector2.ZERO

	# Animation sauber in Idle bringen
	match facing_direction:
		"up": animated_sprite_2d.play("idle_up")
		"down": animated_sprite_2d.play("idle_down")
		"side": animated_sprite_2d.play("idle_side")

func cutscene_end() -> void:
	print("[PlayerRealworld] cutscene_end()")
	can_move = true
	can_interact = true
	is_busy = false
