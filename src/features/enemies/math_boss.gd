extends "res://src/features/enemies/generic_enemy.gd"

@export var boss_trigger: Boss_Trigger

#------------------------------
# Projectile Scenes
#------------------------------
var projectile_scenes: Array = [
	preload("res://src/features/enemies/psych_projectile.tscn"),
	preload("res://src/features/enemies/symbol_one.tscn"),
	preload("res://src/features/enemies/symbol_two.tscn"),
	preload("res://src/features/enemies/symbol_three.tscn"),
	preload("res://src/features/enemies/math_boss_ulti_projectile.tscn")
]


#------------------------------
# Config
#------------------------------
var bar_instance
var projectile_to_spawn := 0
var boss_bar = preload("res://src/features/enemies/math_boss_healthbar.tscn")
var invincible := true
var exhausted := false
var last_attack := ""

var attack_counter := 0

var MAX_ATTACK = 8

@onready var health = $Health

@export var boss_of_level = ""

func _ready() -> void:
	health.immortality = true
	
func _spawn_healthbar() -> void:
	print("spawned healthbar")
	bar_instance = boss_bar.instantiate()
	get_tree().current_scene.add_child(bar_instance)
	bar_instance.setup(self)

func _get_visible_player() -> CharacterBody2D:
	return boss_trigger._get_player()
	
func _detect_player() -> bool:
	var collider := _get_visible_player()
	if collider:
		if bar_instance == null:
			_spawn_healthbar()
		player = collider
		return true
	return false
	
#------------------------------
# Hurt System Logic
#------------------------------
# Fall-Animation wird abgespielt, boss health.immortality wird für 5 sek auf false gesetzt,
# Boss kann nun verletzt werden.
func _exhaust() -> void:
	exhausted = true
	_play_animation_scaled("fall", 0.5)
	await get_tree().create_timer(0.5).timeout
	sprite.play("exhausted")
	invincible = false
	health.immortality = false
	await get_tree().create_timer(5).timeout
	invincible = true
	health.immortality = true
	_play_animation_scaled("get_up", 0.5)
	await get_tree().create_timer(0.5).timeout
	exhausted = false
	
# Angriff beenden, Anzahle Angriffe inkrementieren, Wenn eine Maximalanzahl an Angriffen erreicht ist, 
# exhaust() rufen 
func _end_attack() -> void:
		is_attacking = false
		is_walking = true
		attack_allowed = true
		sprite.play("walk")
		attack_counter += 1
		if attack_counter >= MAX_ATTACK:
			_exhaust()
			attack_counter = 0
	
	
# Wenn nicht 'incincible', Schaden-Signal emittieren
func _on_hurt_box_received_damage(damage: int, _attacker_pos: Vector2) -> void:
	if not invincible:
		if bar_instance != null:
			bar_instance.update()
		flash_anim.play("flash")
		damaged.emit(damage)
		GlobalScript.enemy_damaged.emit(damage)
		_stun()
	
func _handle_player_logic() -> void:
	if not exhausted:
		if _detect_player():
			is_walking = true
			sprite.play("walk")
			_start_attack()
			if not is_dashing:
				_track_player()
		else:
			if bar_instance != null:
				bar_instance.queue_free()
				bar_instance = null
			player = null
			is_walking = true
			sprite.play("walk")
		
func _on_health_depleted() -> void:
	die()
		
func die() -> void:
	bar_instance._deplete()

	queue_free()

# RealWorld-Szene laden
func _return_to_classroom() -> void:
	GlobalScript.save_coins_for_level(boss_of_level)

	await get_tree().create_timer(0.2).timeout

	# Blink Overlay
	var blink_overlay = preload("res://src/shared/components/blink_overlay.tscn").instantiate()
	get_tree().root.add_child(blink_overlay)
	
	var overlay = blink_overlay.get_node("Blink_Overlay")
	# Transition to Real World
	await overlay.play_wake_up()
	GlobalScript.change_scene("realworld_classroom_two")
	
func _stun() -> void:
	is_stunned = true
	attack_token += 1
	_play_animation_scaled("stun", STUN_TIME)
	await get_tree().create_timer(STUN_TIME).timeout
	is_stunned = false
	sprite.play("exhausted")
	
func _physics_process(delta: float) -> void:
		if not exhausted:
			_apply_gravity(delta)
			_process_movement()
			move_and_slide()
			
	
#------------------------------
# Projectile Sequential Spawn Logic
#------------------------------	
# Richtung des Projektils kann hier mit angegeben werden (möglciherweise auch in 
# Generic_Enemy implementieren)
func _spawn_projectile_in_dir(attack: Range_Attack, _direction: Vector2) -> void:
	sound_player.play_sound(Enemysound.soundtype.ATTACK)
	var projectile = projectile_scenes[projectile_to_spawn].instantiate()
	projectile.get_node("HitBox").damage = attack.damage
	projectile.position = position + Vector2(attack.projectile_offset.x * direction, attack.projectile_offset.y)
	projectile.set_direction(_direction)
	projectile.rotation = _direction.angle()
	projectile._set_exception(self)
	get_tree().current_scene.add_child(projectile)

# Hard-gecodete, Boss-Spezifische Methode für Projektil-Instanziierung und Richtungssetzung
# bei spezifischen Attacken
func _coordinate_range_attack(attack: Range_Attack, dir_to_player: Vector2) -> void:
	match attack.pre_animation_name:
		"pre_psych":
			projectile_to_spawn = 0
			_spawn_projectile_in_dir(attack, dir_to_player)
		"symbol_attack":
			projectile_to_spawn = 1
			_spawn_projectile_in_dir(attack, dir_to_player.rotated(deg_to_rad(25)))
			projectile_to_spawn = 2
			_spawn_projectile_in_dir(attack, dir_to_player)
			projectile_to_spawn = 3
			_spawn_projectile_in_dir(attack, dir_to_player.rotated(deg_to_rad(-25)))
		"ultimate":
			projectile_to_spawn = 4
			_spawn_projectile_in_dir(attack, dir_to_player.rotated(deg_to_rad(20)))
			projectile_to_spawn = 4
			_spawn_projectile_in_dir(attack, dir_to_player)
			projectile_to_spawn = 4
			_spawn_projectile_in_dir(attack, dir_to_player.rotated(deg_to_rad(-20)))
		_:
			projectile_to_spawn = 0
			_spawn_projectile_in_dir(attack, Vector2.RIGHT)
			
# Range-Attack mit Berechnung von Richtung zwischen Projektil-Spawnpunkt und Spielerposition
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
	var projectile_position = to_global(Vector2(attack.projectile_offset.x * direction, attack.projectile_offset.y))
	var dir_to_player = Vector2(player.global_position - projectile_position).normalized()
	_coordinate_range_attack(attack, dir_to_player)

	_play_animation_scaled(attack.post_animation_name, attack.post_attack_duration)
	await get_tree().create_timer(attack.post_attack_duration).timeout
	if token != attack_token:
		_end_attack()
		return

	_end_attack()
	attack_allowed = false
	attack_cooldown.start()
	
# Für den Boss einzigartiger Angriff der mehrere exploding-projectiles instanziiert
func ultimate(attack: Range_Attack):
	is_attacking = true
	is_walking = false

	var token := attack_token

	sound_player.play_sound(Enemysound.soundtype.PRE_ATTAK)
	_play_animation_scaled("pre_ulti", 2)
	await get_tree().create_timer(2).timeout
	if token != attack_token:
		_end_attack()
		return

	_play_animation_scaled("ulti", 2)
	var twenty_degrees = Vector2.UP.rotated(deg_to_rad(-20))
	var forty_degrees = Vector2.UP.rotated(deg_to_rad(-40))
	var sixty_degrees = Vector2.UP.rotated(deg_to_rad(-60))
	var eighty_degrees = Vector2.UP.rotated(deg_to_rad(-80))
	
	await get_tree().create_timer(0.5).timeout
	_coordinate_range_attack(attack, Vector2(twenty_degrees.x * -direction, twenty_degrees.y).normalized())
	await get_tree().create_timer(0.5).timeout
	_coordinate_range_attack(attack, Vector2(forty_degrees.x * -direction, twenty_degrees.y).normalized())
	await get_tree().create_timer(0.5).timeout
	_coordinate_range_attack(attack, Vector2(sixty_degrees.x * -direction, twenty_degrees.y).normalized())
	await get_tree().create_timer(0.5).timeout
	_coordinate_range_attack(attack, Vector2(eighty_degrees.x * -direction, twenty_degrees.y).normalized())
	

	_play_animation_scaled("post_ulti", 2)
	await get_tree().create_timer(2).timeout
	if token != attack_token:
		_end_attack()
		return

	_end_attack()
	attack_allowed = false
	attack_cooldown.start()
	
# Angriff-Start-Methode wie in Generic-Enemy mit berücksichtigung der einzigartigen Angriffs-Methode 
# dieses bosses. Die Ultimate-Attacke soll nicht mehr als ein mal hinterienander durchgeführt werden können
func _start_attack() -> void:
	if not attack_allowed or is_attacking or not player:
		return
			
	if attacks.is_empty() and range_attacks.is_empty():
		return

	attack_allowed = false
	sound_player.play_sound(Enemysound.soundtype.ATTACK)

	var distance := player.global_position.distance_to(global_position)

	if attacks.is_empty():
		var attack = _random_range_attack()
		if last_attack == "ultimate":
			for i in range(500):
				if range_attacks.size() < 2:
					break
				if attack.pre_animation_name != "ultimate":
					break
				attack = _random_range_attack()
				
		last_attack = attack.pre_animation_name
			
		if attack.pre_animation_name == "ultimate":
			ultimate(attack)
			return
		_range_attack(attack)
	elif range_attacks.is_empty():
		_attack(_random_melee_attack())
	if not attacks.is_empty() and not range_attacks.is_empty():
		if distance > ATTACK_RANGE_FAR:
			_range_attack(_random_range_attack())
		else:
			_attack(_random_melee_attack())
	
	
