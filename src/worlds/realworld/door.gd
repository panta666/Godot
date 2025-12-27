extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var transition: CanvasLayer = $DoorTransition
@onready var transition_rect: ColorRect = transition.get_node("ColorRect")
@onready var shader_mat: ShaderMaterial = transition_rect.material
@onready var door_open_player: AudioStreamPlayer = $DoorOpenPlayer
@onready var door_closed_player: AudioStreamPlayer = $DoorClosedPlayer
@export var next_scene: String = ""  # Name der Szene, zu der gewechselt wird

@export var door_id: String = "" # z.B. "math_room"
@export var needs_unlock := false

var is_opening := false

func _ready():
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
		

func _on_body_entered(body):
	if is_opening:
		return
	if body != GlobalScript.player:
		return
	
	# Locked Absicherung
	if needs_unlock and not SaveManager.is_door_unlocked(door_id):
		_show_locked_feedback()
		return
		
	is_opening = true
	GlobalScript.player.can_move = false
	set_transition_center(body.global_position)
	await play_door_animation(body)

func _show_locked_feedback():
	if not door_closed_player.playing:
		door_closed_player.play()

func _on_boss_defeated():
	SaveManager.unlock_door("math_room")

func set_transition_center(player_pos: Vector2):
	var viewport = get_viewport()
	var cam = GlobalScript.player.camera_2d
	if cam == null:
		return

	var offset = player_pos - cam.global_position
	var screen_pos = viewport.get_visible_rect().size * 0.5 + offset
	var uv = Vector2(screen_pos.x / viewport.get_visible_rect().size.x,
					 screen_pos.y / viewport.get_visible_rect().size.y)
	shader_mat.set_shader_parameter("center", uv)

# ------------------------------------------------------
# Tür öffnen + Szenenwechsel vorbereiten
# ------------------------------------------------------
func play_door_animation(_player_node):
	# Türgeräusch
	door_open_player.play()

	# Türanimation starten (parallel)
	_door_animation()

	# Fade-Out
	var fade_task = await _fade_out(1.0)
	await fade_task

	# Szenenwechsel
	if next_scene != "":
		GlobalScript.previous_scene = GlobalScript.current_scene
		GlobalScript.current_scene = next_scene
		# Speichert, welche Tür den Wechsel ausgelöst hat
		GlobalScript.last_door_for_transition = self
		GlobalScript.change_scene(next_scene)

	is_opening = false
	GlobalScript.player.can_move = true

# ------------------------------------------------------
# Türanimation
# ------------------------------------------------------
func _door_animation():
	if anim.sprite_frames.has_animation("door_opened"):
		anim.play("door_opened")
		await get_tree().create_timer(1.0).timeout
	if anim.sprite_frames.has_animation("door_closed"):
		anim.play("door_closed")

# ------------------------------------------------------
# Shader Fade-Out (von außen nach innen)
# ------------------------------------------------------
func _fade_out(duration):
	transition_rect.visible = true
	var t = 0.0
	while t < duration:
		t += get_process_delta_time()
		var r = lerp(1.0, 0.0, t / duration)
		shader_mat.set_shader_parameter("radius", r)
		await get_tree().process_frame
	shader_mat.set_shader_parameter("radius", 0.0)

# ------------------------------------------------------
# Shader Fade-In (von innen nach außen)
# ------------------------------------------------------
func _fade_in(duration):
	transition_rect.visible = true
	var t = 0.0
	while t < duration:
		t += get_process_delta_time()
		var r = lerp(0.0, 1.0, t / duration)
		shader_mat.set_shader_parameter("radius", r)
		await get_tree().process_frame
	shader_mat.set_shader_parameter("radius", 1.0)
	transition_rect.visible = false
