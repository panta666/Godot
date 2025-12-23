extends CharacterBody2D
class_name Enemy

# -------------------------------------------------------------------
# CONFIG
# -------------------------------------------------------------------
@export var attacks: Array[Attack] = []
@export var range_attacks: Array[Range_Attack] = []

@export var health_bar_position: Vector2 = Vector2(0, -30)


const SPEED := 50.0
const DASH_SPEED := 300.0
const STUN_TIME := 0.35

const ATTACK_RANGE := 260.0
const ATTACK_RANGE_FAR := 166.0
const ATTACK_RANGE_NEAR := 165.0

# -------------------------------------------------------------------
# RESOURCES
# -------------------------------------------------------------------
var projectile_scene := preload("res://scenes/Enemies/Projectile.tscn")
var healthbar_scene := preload("res://scenes/Enemies/enemy_health_bar.tscn")

# -------------------------------------------------------------------
# STATE
# -------------------------------------------------------------------
var direction := 1
var is_walking := true
var is_dashing := false
var is_stunned := false
var is_attacking := false
var attack_allowed := true
var attack_token := 0

var player: CharacterBody2D
var healthbar

var knockback_timer := 0.0
var knockback_duration := 0.2

var carried_item = null

# -------------------------------------------------------------------
# NODES
# -------------------------------------------------------------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var flash_anim: AnimationPlayer = $AnimatedSprite2D/FlashAnimation

@onready var ray_down: RayCast2D = $RaycastDownRight
@onready var ray_forward: RayCast2D = $RayCastRight

@onready var vision_front: RayCast2D = $Vision_Front
@onready var vision_back: RayCast2D = $Vision_Back
@onready var tracking_box: Area2D = $Tracking_Box
@onready var hitbox := $HitBox/CollisionShape2D

@onready var attack_cooldown: Timer = $Attack_Cooldown
@onready var dashing_timer: Timer = $DashingTimer

@onready var sound_player: Node2D = $EnemySoundPlayer

# -------------------------------------------------------------------
# LIFECYCLE
# -------------------------------------------------------------------
func _ready() -> void:
	call_deferred("_spawn_healthbar")

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_process_movement()
	move_and_slide()

# -------------------------------------------------------------------
# MOVEMENT
# -------------------------------------------------------------------
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _process_movement() -> void:
	if not is_on_floor() or is_stunned:
		return

	if not is_attacking:
		_handle_navigation()
		_handle_player_logic()

	velocity.x = _get_horizontal_speed()

func _get_horizontal_speed() -> float:
	if not is_walking:
		return 0.0
	return direction * (DASH_SPEED if is_dashing else SPEED)

func _handle_navigation() -> void:
	if not ray_down.is_colliding() or ray_forward.is_colliding():
		_flip_direction()

func _flip_direction() -> void:
	direction *= -1
	transform.x = Vector2(direction * abs(scale.x), 0)
	#ray_forward.target_position.x = abs(ray_forward.target_position.x) * direction

# -------------------------------------------------------------------
# PLAYER LOGIC
# -------------------------------------------------------------------
func _handle_player_logic() -> void:
	if _detect_player():
		is_walking = true
		sprite.play("walk")
		_start_attack()
		if not is_dashing:
			_track_player()
	else:
		if _is_player_in_tracking_box():
			if not is_dashing:
				is_walking = false
				sprite.play("idle")
				sound_player.stop_move_sound()
		else:
			player = null
			is_walking = true
			sprite.play("walk")
			sound_player.play_sound(Enemysound.soundtype.WALK)

func _detect_player() -> bool:
	var collider := _get_visible_player()
	if collider:
		player = collider
		return true
	return false

func _get_visible_player() -> CharacterBody2D:
	for ray in [vision_front, vision_back]:
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider.is_in_group("player"):
				return collider
	return null

func _is_player_in_tracking_box() -> bool:
	return player and player in tracking_box.get_overlapping_bodies()

func _track_player() -> void:
	if not player:
		return

	if abs(player.global_position.x - global_position.x) <= 15:
		return

	direction = sign(player.global_position.x - global_position.x)
	transform.x = Vector2(direction * abs(scale.x), 0)
	#ray_forward.target_position.x = abs(ray_forward.target_position.x) * direction

# -------------------------------------------------------------------
# COMBAT
# -------------------------------------------------------------------
func _start_attack() -> void:
	if not attack_allowed or is_attacking or not player:
		return
		
	if attacks.is_empty() and range_attacks.is_empty():
		print("Even the confusion is confused")
		return

	attack_allowed = false
	sound_player.play_sound(Enemysound.soundtype.ATTACK)

	var distance := player.global_position.distance_to(global_position)

	if attacks.is_empty():
		_range_attack(_random_range_attack())
	elif range_attacks.is_empty():
		_attack(_random_melee_attack())
	if not attacks.is_empty() and not range_attacks.is_empty():
		if distance > ATTACK_RANGE_FAR:
			_range_attack(_random_range_attack())
		else:
			_attack(_random_melee_attack())
			

func _random_melee_attack() -> Attack:
	return attacks.pick_random()

func _random_range_attack() -> Range_Attack:
	return range_attacks.pick_random()

# -------------------------------------------------------------------
# MELEE ATTACK
# -------------------------------------------------------------------
func _attack(attack: Attack) -> void:
	is_attacking = true
	is_walking = false
	
	var token := attack_token
	
	_prepare_hitbox(attack)
	_play_animation_scaled(attack.pre_animation_name, attack.pre_attack_duration)
	await get_tree().create_timer(attack.pre_attack_duration).timeout
	if token != attack_token:
		_end_attack()
		return

	_execute_attack_movement(attack)
	_play_animation_scaled(attack.animation_name, _get_attack_duration(attack))
	_enable_hitbox()
	await get_tree().create_timer(_get_attack_duration(attack)).timeout
	if token != attack_token:
		_end_attack()
		return

	_disable_hitbox()
	is_walking = false
	_play_animation_scaled(attack.post_animation_name, attack.post_attack_duration)
	await get_tree().create_timer(attack.post_attack_duration).timeout
	if token != attack_token:
		_end_attack()
		return

	_end_attack()
	attack_allowed = false
	attack_cooldown.start()

func _prepare_hitbox(attack: Attack) -> void:
	hitbox.position = attack.hitbox_offset
	(hitbox.shape as RectangleShape2D).extents = attack.hitbox_size
	$HitBox.damage = attack.damage

func _disable_hitbox() -> void:
	hitbox.disabled = true
	
func _enable_hitbox() -> void:
	hitbox.disabled = false


func _execute_attack_movement(attack: Attack) -> void:
	match attack.movement:
		attack.movement_type.DASH:
			is_walking = true
			_start_dash()
		attack.movement_type.NONE:
			return

func _get_attack_duration(attack: Attack) -> float:
	return dashing_timer.wait_time if is_dashing else attack.hitbox_duration

# -------------------------------------------------------------------
# RANGE ATTACK
# -------------------------------------------------------------------
func _range_attack(attack: Range_Attack) -> void:
	is_attacking = true
	is_walking = false

	var token := attack_token

	sound_player.play_sound(Enemysound.soundtype.PRE_ATTAK)
	_play_animation_scaled(attack.pre_animation_name, attack.pre_attack_duration)
	await get_tree().create_timer(attack.pre_attack_duration).timeout
	if token != attack_token:
		_end_attack()
		return

	_spawn_projectile(attack)

	_play_animation_scaled(attack.post_animation_name, attack.post_attack_duration)
	await get_tree().create_timer(attack.post_attack_duration).timeout
	if token != attack_token:
		_end_attack()
		return

	_end_attack()
	attack_allowed = false
	attack_cooldown.start()

func _spawn_projectile(attack: Range_Attack) -> void:
	sound_player.play_sound(Enemysound.soundtype.ATTACK)
	var projectile = projectile_scene.instantiate()
	projectile.get_node("HitBox").damage = attack.damage
	projectile.position = position + attack.projectile_offset * direction
	projectile.direction = Vector2.RIGHT * direction
	projectile._set_exception(self)
	get_tree().current_scene.add_child(projectile)
	
func _end_attack() -> void:
		is_attacking = false
		is_walking = true
		attack_allowed = true
		sprite.play("walk")

# -------------------------------------------------------------------
# UTILS
# -------------------------------------------------------------------
func _play_animation_scaled(name: String, duration: float) -> void:
	var frames := sprite.sprite_frames
	var speed := frames.get_frame_count(name) / duration
	frames.set_animation_speed(name, speed)
	sprite.play(name)

func _start_dash() -> void:
	if is_dashing:
		return
	is_dashing = true
	dashing_timer.start()

func _stun() -> void:
	is_stunned = true
	attack_token += 1
	_play_animation_scaled("stun", STUN_TIME)
	await get_tree().create_timer(STUN_TIME).timeout
	is_stunned = false

# -------------------------------------------------------------------
# HEALTH / DAMAGE
# -------------------------------------------------------------------
func _spawn_healthbar() -> void:
	healthbar = healthbar_scene.instantiate()
	get_tree().root.add_child(healthbar)
	healthbar.setup(self)

func _on_hurt_box_received_damage(_damage: int, attacker_pos: Vector2) -> void:
	flash_anim.play("flash")
	_apply_knockback(attacker_pos)
	healthbar.update()
	_stun()

func _apply_knockback(attacker_pos: Vector2) -> void:
	var dir = sign(global_position.x - attacker_pos.x)
	velocity = Vector2(dir * 200.0, -80.0)
	knockback_timer = knockback_duration

func _on_health_depleted() -> void:
	healthbar._deplete()
	if carried_item != null:
		print("drop")
		var item = carried_item.instantiate()
		get_parent().add_child(item)
		item.global_position = global_position
	queue_free()

func _on_dashing_timer_timeout() -> void:
	is_dashing = false

func _on_attack_cooldown_timeout() -> void:
	attack_allowed = true
	
func give_item(item_scene):
	carried_item = item_scene
