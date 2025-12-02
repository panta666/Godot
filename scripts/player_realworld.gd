extends CharacterBody2D
class_name PlayerRealworld

const SPEED = 120.0
const SCALE_FACTOR = 1.5

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var footstep_player = $FootstepPlayer

var facing_direction: String = "down"
var sitting: bool = false

# --- Quest Tracker ---
@onready var quest_arrow: Node2D = $QuestArrow

# --- Bewegung & Interaktion Flags ---
var can_move: bool = true
var can_interact: bool = true
var is_busy: bool = false

# --- Handy Callback ---
var _mobile_callback: Callable

# Sounds für random footsteps
const FOOTSTEP_SOUNDS = [
	preload("res://assets/sfx/kenney_impact-sounds/Audio/footstep_wood_001.ogg"),
	preload("res://assets/sfx/kenney_impact-sounds/Audio/footstep_wood_002.ogg"),
	preload("res://assets/sfx/kenney_impact-sounds/Audio/footstep_wood_003.ogg"),
	preload("res://assets/sfx/kenney_impact-sounds/Audio/footstep_wood_004.ogg")
]

const FOOTSTEP_FRAMES = {"walk_side":[1,4], "walk_up":[1,4], "walk_down":[1,4]}

# ===========================
# READY
# ===========================
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
			
	# --------------------------
	# TEST: Questziel setzen
	# --------------------------
	# Prüfen, ob die Node existiert
	var classroom_door_path = "Classroom_Door_One" # relativ zum Root deiner Szene
	if get_tree().current_scene.has_node(classroom_door_path):
		var classroom_door = get_tree().current_scene.get_node(classroom_door_path)
		set_quest_target(classroom_door)
		print("[TEST] Questziel Classroom_Door_One gesetzt:", classroom_door)
	else:
		print("[TEST] Classroom_Door_One existiert nicht in dieser Szene")

# ===========================
# PHYSICS PROCESS
# ===========================
func _physics_process(_delta: float) -> void:
	if not can_move:
		return

	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	velocity = input_vector * SPEED
	move_and_slide()

	# Animation
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

# ===========================
# HANDY / ESC
# ===========================
func open_mobile(callback: Callable) -> void:
	_mobile_callback = callback
	animated_sprite_2d.play("mobile_hand")
	if animated_sprite_2d.animation_finished.is_connected(_on_mobile_hand_finished):
		animated_sprite_2d.animation_finished.disconnect(_on_mobile_hand_finished)
	animated_sprite_2d.animation_finished.connect(_on_mobile_hand_finished)

func _on_mobile_hand_finished() -> void:
	if animated_sprite_2d.animation == "mobile_hand":
		if animated_sprite_2d.animation_finished.is_connected(_on_mobile_hand_finished):
			animated_sprite_2d.animation_finished.disconnect(_on_mobile_hand_finished)
		animated_sprite_2d.play("mobile_idle")
		if _mobile_callback != null and _mobile_callback.is_valid():
			_mobile_callback.call()
			_mobile_callback = Callable()

func close_mobile(callback: Callable = Callable()) -> void:
	_mobile_callback = callback
	animated_sprite_2d.play("mobile_pocket")
	if animated_sprite_2d.animation_finished.is_connected(_on_mobile_pocket_finished):
		animated_sprite_2d.animation_finished.disconnect(_on_mobile_pocket_finished)
	animated_sprite_2d.animation_finished.connect(_on_mobile_pocket_finished)

func _on_mobile_pocket_finished() -> void:
	if animated_sprite_2d.animation == "mobile_pocket":
		if animated_sprite_2d.animation_finished.is_connected(_on_mobile_pocket_finished):
			animated_sprite_2d.animation_finished.disconnect(_on_mobile_pocket_finished)
		animated_sprite_2d.play("idle_down")
	if _mobile_callback != null and _mobile_callback.is_valid():
		_mobile_callback.call()
		_mobile_callback = Callable()

# ===========================
# HILFSFUNKTIONEN
# ===========================
func set_facing_direction(dir: String) -> void:
	facing_direction = dir

func get_facing_direction() -> String:
	return facing_direction

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
	if footstep_player.is_playing():
		return
	footstep_player.stream = FOOTSTEP_SOUNDS.pick_random()
	footstep_player.pitch_scale = randf_range(0.9, 1.1)
	footstep_player.play()

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
		or animated_sprite_2d.animation == "walk_side"
		or animated_sprite_2d.animation == "walk_up"):
		if animated_sprite_2d.frame in FOOTSTEP_FRAMES[animated_sprite_2d.animation]:
			play_footstep_sound()

func cutscene_start() -> void:
	can_move = false
	can_interact = false
	is_busy = true
	velocity = Vector2.ZERO
	match facing_direction:
		"up": animated_sprite_2d.play("idle_up")
		"down": animated_sprite_2d.play("idle_down")
		"side": animated_sprite_2d.play("idle_side")

func cutscene_end() -> void:
	can_move = true
	can_interact = true
	is_busy = false

func _update_animation_from_vector(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play("walk_side")
		facing_direction = "side"
	elif dir.y < 0:
		animated_sprite_2d.play("walk_up")
		facing_direction = "up"
	else:
		animated_sprite_2d.play("walk_down")
		facing_direction = "down"

# ===========================
# QUEST ARROW DYNAMISCH
# ===========================
func set_quest_target(target_node: Node2D) -> void:
	if quest_arrow:
		quest_arrow.set_target(target_node)
