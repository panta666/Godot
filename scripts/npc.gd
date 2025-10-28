@tool
extends CharacterBody2D

@export var npc_data: NPCData

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var name_label: Label = $NameLabel
@onready var interactable: Area2D = $Interactable
@onready var interact_range: Area2D = $InteractRange
@onready var player: PlayerRealworld = $"../Player_Realworld"

# --- Status & Verhalten ---
var dialog_active: bool = false
var dialog_instance: Node = null
var idle_timer: Timer
var current_target: Vector2 = Vector2.ZERO

# --- Pfadbezogen ---
var path_follow: PathFollow2D = null
var current_facing: String = "down"
var patrol_forward: bool = true
var last_path_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	if not npc_data:
		push_error("Kein NPCData zugewiesen für " + name)
		return

	# Grunddaten
	animated_sprite.sprite_frames = npc_data.sprite_frames
	name_label.text = npc_data.npc_name
	name_label.visible = false
	_set_facing(npc_data.start_facing)

	# Interaktion
	if npc_data.can_talk:
		interactable.interact_name = "Press F to talk"
		interactable.interact = _on_interact
		interactable.is_interactable = false
		interact_range.connect("body_entered", Callable(self, "_on_range_entered"))
		interact_range.connect("body_exited", Callable(self, "_on_range_exited"))
	else:
		interactable.is_interactable = false
		interactable.interact_name = ""

	# Timer für Idle / Random Walk
	idle_timer = Timer.new()
	idle_timer.wait_time = npc_data.wander_interval
	idle_timer.one_shot = false
	idle_timer.autostart = true
	add_child(idle_timer)
	idle_timer.connect("timeout", Callable(self, "_on_idle_behavior"))

	# PathFollow Setup für Patrol
	if not Engine.is_editor_hint() and npc_data.behavior_type == npc_data.BehaviorType.PATROL and npc_data.path_node != null:
		var path = get_node_or_null(npc_data.path_node)
		if path and path is Path2D:
			path_follow = path.get_node_or_null("Follow") as PathFollow2D
			if not path_follow:
				path_follow = PathFollow2D.new()
				path_follow.name = "Follow"
				path.add_child(path_follow)
			path_follow.loop = false
			path_follow.rotates = false
			if get_parent() != path_follow:
				path_follow.add_child(self)
				position = Vector2.ZERO
			last_path_pos = path_follow.global_position


func _physics_process(delta: float) -> void:
	if dialog_active:
		return

	match npc_data.behavior_type:
		npc_data.BehaviorType.RANDOM_WALK:
			_random_walk(delta)
		npc_data.BehaviorType.PATROL:
			_patrol(delta)
		_:
			pass


# --------------------------
# Idle / Random Walk
# --------------------------
func _on_idle_behavior() -> void:
	if dialog_active:
		return

	match npc_data.behavior_type:
		npc_data.BehaviorType.IDLE_TURN:
			_turn_random()
		npc_data.BehaviorType.RANDOM_WALK:
			_set_random_target()


func _turn_random() -> void:
	var dirs = ["up", "down", "left", "right"]
	_set_facing(dirs[randi() % dirs.size()])


func _set_random_target() -> void:
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	current_target = global_position + directions[randi() % directions.size()] * 32


func _random_walk(delta: float) -> void:
	if current_target == Vector2.ZERO:
		return

	var dir_vec = current_target - global_position
	if dir_vec.length() < 4:
		velocity = Vector2.ZERO
		animated_sprite.play(_idle_animation_for_current_facing())
		return

	if abs(dir_vec.x) > abs(dir_vec.y):
		dir_vec = Vector2(sign(dir_vec.x), 0)
	else:
		dir_vec = Vector2(0, sign(dir_vec.y))

	velocity = dir_vec * npc_data.move_speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		_set_random_target()
		velocity = Vector2.ZERO
		animated_sprite.play(_idle_animation_for_current_facing())
	else:
		_update_walk_animation(dir_vec)


# --------------------------
# Patrol über PathFollow2D
# --------------------------
func _patrol(delta: float) -> void:
	if not path_follow:
		return

	var curve = path_follow.get_parent().curve
	if not curve:
		return

	var speed = npc_data.move_speed * delta
	if patrol_forward:
		path_follow.progress += speed
	else:
		path_follow.progress -= speed

	var curve_length = curve.get_baked_length()

	# Richtung umkehren am Ende
	if path_follow.progress >= curve_length:
		path_follow.progress = curve_length
		patrol_forward = false
	elif path_follow.progress <= 0:
		path_follow.progress = 0
		patrol_forward = true

	# Bewegung direkt übernehmen (keine Physics-Collision)
	global_position = path_follow.global_position

	# Richtung berechnen anhand der Bewegung entlang des Pfads
	var dir_vec = (path_follow.global_position - last_path_pos).normalized()
	last_path_pos = path_follow.global_position

	if dir_vec.length() > 0.05:
		_update_walk_animation(dir_vec)
	else:
		animated_sprite.play(_idle_animation_for_current_facing())


# --------------------------
# Walk Animation Helper
# --------------------------
func _update_walk_animation(dir_vec: Vector2) -> void:
	if abs(dir_vec.x) > abs(dir_vec.y):
		if dir_vec.x > 0:
			current_facing = "right"
			animated_sprite.flip_h = false
			animated_sprite.play(npc_data.walk_side)
		else:
			current_facing = "left"
			animated_sprite.flip_h = true
			animated_sprite.play(npc_data.walk_side)
	else:
		if dir_vec.y > 0:
			current_facing = "down"
			animated_sprite.play(npc_data.walk_down)
		else:
			current_facing = "up"
			animated_sprite.play(npc_data.walk_up)


func _idle_animation_for_current_facing() -> String:
	match current_facing:
		"up":
			return npc_data.idle_up
		"down":
			return npc_data.idle_down
		"left", "right":
			return npc_data.idle_side
		_:
			return npc_data.idle_down


# --------------------------
# Interaktion & Dialog
# --------------------------
func _on_range_entered(body: Node) -> void:
	if body == player:
		if not npc_data.can_talk:
			name_label.visible = false
			return
		name_label.visible = true
		if not dialog_active:
			interactable.is_interactable = true
		if player.has_node("InteractingComponent"):
			var ic = player.get_node("InteractingComponent")
			ic._on_interact_range_area_entered(interactable)


func _on_range_exited(body: Node) -> void:
	if body == player:
		name_label.visible = false
		if not npc_data.can_talk:
			return
		interactable.is_interactable = false
		if player.has_node("InteractingComponent"):
			var ic = player.get_node("InteractingComponent")
			ic._on_interact_range_area_exited(interactable)


func _on_interact() -> void:
	if dialog_active or not npc_data.can_talk:
		return
	if npc_data.dialog_timeline_path == "":
		push_warning(npc_data.npc_name + " hat keine Dialog-Timeline zugewiesen.")
		return

	dialog_active = true
	interactable.is_interactable = false

	if player:
		player.can_move = false
		if player.has_node("InteractingComponent"):
			var ic = player.get_node("InteractingComponent")
			ic.can_interact = false

	_face_player()

	dialog_instance = Dialogic.start(npc_data.dialog_timeline_path)
	if dialog_instance:
		get_tree().root.add_child(dialog_instance)
		if dialog_instance.has_signal("timeline_ended"):
			dialog_instance.connect("timeline_ended", Callable(self, "_on_dialog_ended"))
		elif dialog_instance.has_signal("dialogic_timeline_end"):
			dialog_instance.connect("dialogic_timeline_end", Callable(self, "_on_dialog_ended"))
		else:
			dialog_instance.connect("tree_exited", Callable(self, "_on_dialog_ended"))


func _on_dialog_ended() -> void:
	if not dialog_active:
		return

	dialog_active = false

	if dialog_instance and dialog_instance.get_parent():
		dialog_instance.queue_free()
	dialog_instance = null

	if player:
		player.can_move = true
		if player.has_node("InteractingComponent"):
			var ic = player.get_node("InteractingComponent")
			ic.can_interact = true

	if player_in_range():
		interactable.is_interactable = true


# --------------------------
# Hilfsfunktionen
# --------------------------
func _face_player() -> void:
	if not player:
		return
	var dir = player.global_position - global_position
	if abs(dir.x) > abs(dir.y):
		_set_facing("right" if dir.x > 0 else "left")
	else:
		_set_facing("down" if dir.y > 0 else "up")


func _set_facing(dir: String) -> void:
	current_facing = dir
	match dir:
		"left":
			animated_sprite.flip_h = true
			animated_sprite.play(npc_data.idle_side)
		"right":
			animated_sprite.flip_h = false
			animated_sprite.play(npc_data.idle_side)
		"up":
			animated_sprite.play(npc_data.idle_up)
		_:
			animated_sprite.play(npc_data.idle_down)


func player_in_range() -> bool:
	return interact_range.get_overlapping_bodies().has(player)
