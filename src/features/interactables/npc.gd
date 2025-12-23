@tool
extends CharacterBody2D

@export var npc_data: NPCData

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var name_label: Label = $NameLabel
@onready var interactable: Area2D = $Interactable
@onready var interact_range: Area2D = $InteractRange

var player: PlayerRealworld = null
var dialog_active: bool = false
var dialog_instance: Node = null
var idle_timer: Timer
var current_target: Vector2 = Vector2.ZERO
var path_follow: PathFollow2D = null
var current_facing: String = "down"
var patrol_forward: bool = true
var last_path_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	call_deferred("_setup_player")
	if not npc_data:
		push_warning("NPC '%s' hat kein NPCData – Skipping setup" % name)
		return
	if not animated_sprite:
		push_warning("NPC '%s' hat kein AnimatedSprite2D – Skipping animation setup" % name)
		return

	animated_sprite.sprite_frames = npc_data.sprite_frames
	name_label.text = npc_data.npc_name
	name_label.visible = false
	var start_dir = npc_data.start_facing if npc_data.start_facing != "" else "down"
	_set_facing(start_dir)

	if npc_data.can_talk:
		interactable.interact_name = "to talk"
		interactable.interact = _on_interact
		interactable.is_interactable = false
		interact_range.connect("body_entered", Callable(self, "_on_range_entered"))
		interact_range.connect("body_exited", Callable(self, "_on_range_exited"))
	else:
		interactable.is_interactable = false

	idle_timer = Timer.new()
	idle_timer.wait_time = npc_data.wander_interval
	idle_timer.one_shot = false
	idle_timer.autostart = true
	add_child(idle_timer)
	idle_timer.connect("timeout", Callable(self, "_on_idle_behavior"))

	if npc_data.behavior_type == npc_data.BehaviorType.PATROL and npc_data.path_node != null:
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

	Dialogic.signal_event.connect(Callable(self, "_on_dialogic_signal"))

func _physics_process(delta: float) -> void:
	if dialog_active or not player or not npc_data:
		return
	match npc_data.behavior_type:
		npc_data.BehaviorType.RANDOM_WALK:
			_random_walk(delta)
		npc_data.BehaviorType.PATROL:
			_patrol(delta)
		_:
			pass

func _on_idle_behavior() -> void:
	if dialog_active or not player or not npc_data:
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
		if animated_sprite:
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
		if animated_sprite:
			animated_sprite.play(_idle_animation_for_current_facing())
	else:
		_update_walk_animation(dir_vec)

func _patrol(delta: float) -> void:
	if not path_follow or not npc_data:
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
	if path_follow.progress >= curve_length:
		path_follow.progress = curve_length
		patrol_forward = false
	elif path_follow.progress <= 0:
		path_follow.progress = 0
		patrol_forward = true
	global_position = path_follow.global_position
	var dir_vec = (path_follow.global_position - last_path_pos).normalized()
	last_path_pos = path_follow.global_position
	if dir_vec.length() > 0.05:
		_update_walk_animation(dir_vec)
	elif animated_sprite:
		animated_sprite.play(_idle_animation_for_current_facing())

func _update_walk_animation(dir_vec: Vector2) -> void:
	if not animated_sprite or not npc_data:
		return
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
	if not npc_data:
		return ""
	match current_facing:
		"up": return npc_data.idle_up
		"down": return npc_data.idle_down
		"left", "right": return npc_data.idle_side
		_: return npc_data.idle_down

func _on_range_entered(body: Node) -> void:
	if not player or body != player or not npc_data:
		return
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
	if not player or body != player or not npc_data:
		return
	name_label.visible = false
	if not npc_data.can_talk:
		return
	interactable.is_interactable = false
	if player.has_node("InteractingComponent"):
		var ic = player.get_node("InteractingComponent")
		ic._on_interact_range_area_exited(interactable)

func _on_interact() -> void:
	if not player or dialog_active or not npc_data or not npc_data.can_talk:
		return
	if npc_data.dialog_timeline_path == "":
		push_warning(npc_data.npc_name + " hat keine Dialog-Timeline zugewiesen.")
		return
	dialog_active = true
	interactable.is_interactable = false
	player.can_move = false
	player.is_busy = true
	if player.has_node("InteractingComponent"):
		var ic = player.get_node("InteractingComponent")
		ic.can_interact = false
	_face_player()
	if player and is_instance_valid(player):
		player._face_npc(global_position)
	for child in get_tree().root.get_children():
		if "DialogicLayout" in child.name:
			child.queue_free()
	dialog_instance = Dialogic.start(npc_data.dialog_timeline_path)
	if npc_data.dialogic_character:
		dialog_instance.register_character(npc_data.dialogic_character, self)
	else:
		push_warning("Kein Dialogic-Character in NPCData gesetzt für " + npc_data.npc_name)
	if dialog_instance:
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
		player.is_busy = false
		if player.has_node("InteractingComponent"):
			var ic = player.get_node("InteractingComponent")
			ic.can_interact = true
	if player_in_range():
		interactable.is_interactable = true

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
	if not npc_data or not animated_sprite or not animated_sprite.sprite_frames:
		return
	var anim_to_play = ""
	match dir:
		"left":
			animated_sprite.flip_h = true
			anim_to_play = npc_data.idle_side
		"right":
			animated_sprite.flip_h = false
			anim_to_play = npc_data.idle_side
		"up":
			anim_to_play = npc_data.idle_up
		_:
			anim_to_play = npc_data.idle_down
	if anim_to_play != "" and animated_sprite.sprite_frames.has_animation(anim_to_play):
		animated_sprite.play(anim_to_play)
	else:
		var anims = animated_sprite.sprite_frames.get_animation_names()
		if anims.size() > 0:
			animated_sprite.play(anims[0])
			push_warning("NPC '%s': Animation '%s' nicht gefunden, spiele '%s'" % [name, anim_to_play, anims[0]])

func _on_dialogic_signal(argument: String):
	if argument == "go_home":
		get_tree().quit()

func player_in_range() -> bool:
	return player and interact_range.get_overlapping_bodies().has(player)

func _setup_player() -> void:
	if GlobalScript.player and is_instance_valid(GlobalScript.player):
		player = GlobalScript.player
	else:
		await get_tree().process_frame
		if GlobalScript.player and is_instance_valid(GlobalScript.player):
			player = GlobalScript.player
		else:
			player = null
			push_warning("Kein gültiger Player: " + name)
