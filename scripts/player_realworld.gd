extends CharacterBody2D
class_name PlayerRealworld

const SPEED = 120.0
const SCALE_FACTOR = 1.5

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D

var facing_direction: String = "down"
var sitting: bool = false
var can_move: bool = true

# Sounds für random footsteps
const FOOTSTEP_SOUNDS = [
	preload("res://assets/sfx/kenney_impact-sounds/Audio/footstep_wood_001.ogg"),
	preload("res://assets/sfx/kenney_impact-sounds/Audio/footstep_wood_002.ogg"),
	preload("res://assets/sfx/kenney_impact-sounds/Audio/footstep_wood_003.ogg"),
	preload("res://assets/sfx/kenney_impact-sounds/Audio/footstep_wood_004.ogg")
]

@onready var footstep_player = $FootstepPlayer

func _ready() -> void:
	# Skalierung
	scale = Vector2(SCALE_FACTOR, SCALE_FACTOR)

	# --- Player global registrieren ---
	if not Engine.is_editor_hint():
		GlobalScript.player = self

	# --- Aktivierung abhängig von Szene ---
	if get_tree().current_scene and get_tree().current_scene.name == "MainMenu":
		disable_player()
	else:
		enable_player()
		if camera_2d:
			camera_2d.make_current()

	set_process(true)
	set_physics_process(true)


func _physics_process(_delta: float) -> void:
	if not can_move:
		return

	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	velocity = input_vector * SPEED
	move_and_slide()

	# --- Animationen ---
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
		play_footstep_sound()


# --- Hilfsfunktionen ---
func set_facing_direction(dir: String) -> void:
	facing_direction = dir

func get_facing_direction() -> String:
	return facing_direction

func player():
	pass

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
	velocity = Vector2.ZERO
	animated_sprite_2d.flip_h = false
	animated_sprite_2d.play("sit")


func stand_up(target_pos: Vector2) -> void:
	sitting = false
	can_move = true
	global_position = target_pos
	animated_sprite_2d.play("idle_down")


# --- Aktivierung / Deaktivierung für MainMenu ---
func disable_player() -> void:
	can_move = false
	set_process(false)
	set_physics_process(false)
	animated_sprite_2d.stop()
	visible = false

func enable_player() -> void:
	can_move = true
	set_process(true)
	set_physics_process(true)
	visible = true
