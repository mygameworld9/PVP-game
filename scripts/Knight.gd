extends CharacterBody2D

# Character Stats
@export var character_name: String = "Knight"
@export var max_health: int = 150
@export var movement_speed: float = 180.0
@export var attack_damage: int = 35
@export var attack_style: String = "melee"
@export var attack_range: float = 60.0

# Skills
@export var skills: Array[String] = ["basic_attack", "shield_bash", "battle_cry"]
@export var skill_cooldowns: Dictionary = {}

# Current Stats
var current_health: int
var is_alive: bool = true

# State Machine
var current_state: String = "idle"

# Components
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var attack_area: Area2D = $AttackArea
@onready var atk_collision_shape: CollisionShape2D = $AttackArea/atkCollisionShape2D

# Movement
var input_vector: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.RIGHT

# Jumping
var jump_force: float = -400.0
var gravity: float = 980.0
var is_jumping: bool = false
var can_jump: bool = true

func _ready():
	current_health = max_health
	_setup_state_machine()
	_setup_health_bar()
	_update_health_display()
	_setup_collision_layers()
	
	# Set Knight-specific stats
	character_name = "Knight"
	max_health = 150
	movement_speed = 180.0
	attack_damage = 35
	attack_style = "melee"
	attack_range = 60.0
	
	# Knight skills
	skills = ["basic_attack", "shield_bash", "battle_cry"]
	skill_cooldowns = {
		"shield_bash": 0.0,
		"battle_cry": 0.0
	}
	
	# Update current health after setting max_health
	current_health = max_health
	_update_health_display()

func _setup_state_machine():
	current_state = "idle"

func _setup_health_bar():
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health

func _update_health_display():
	if health_bar:
		health_bar.value = current_health

func _setup_collision_layers():
	# Set collision layers and masks for character
	# Layer 1: Characters (collision layer)
	# Layer 2: Ground/Tiles (collision mask)
	collision_layer = 2  # Characters are on layer 2
	collision_mask = 1   # Characters can collide with layer 1 (ground)

func _physics_process(delta):
	# Handle movement input
	_handle_input()
	
	# Update state based on input
	_update_state()
	
	# Apply gravity
	velocity.y += gravity * delta
	
	# Apply movement
	if input_vector != Vector2.ZERO:
		velocity.x = input_vector.x * movement_speed
		facing_direction = input_vector.normalized()
	else:
		velocity.x = 0
	
	# Handle jumping
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = jump_force
		is_jumping = true
		can_jump = false
		print("Knight jumps!")
	
	# Check if landed
	if is_on_floor():
		is_jumping = false
		can_jump = true
	
	move_and_slide()

func _update_state():
	# 如果角色正在攻击、受伤或已倒下，则不要根据移动来更新状态
	if current_state == "attacking" or current_state == "taking_damage" or current_state == "defeated":
		return # 提前退出函数，不执行下面的逻辑

	if is_jumping:
		current_state = "jumping"
		_update_animation()
		return
	
	if input_vector != Vector2.ZERO:
		if abs(input_vector.x) > 0.5:
			current_state = "walking"
		else:
			current_state = "idle"
	else:
		current_state = "idle"
	
	_update_animation()

func _update_animation():
	if animated_sprite:
		match current_state:
			"idle":
				animated_sprite.play("idle")
			"walking":
				animated_sprite.play("walk")
			"running":
				animated_sprite.play("run")
			"jumping":
				animated_sprite.play("idle")  # Use idle animation for jumping for now
			"attacking":
				animated_sprite.play("attack1")
			"taking_damage":
				animated_sprite.play("damage")
			"defeated":
				animated_sprite.play("defeat")

func _handle_input():
	# 如果角色已死亡，不处理输入
	if not is_alive:
		return
	
	input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	
	input_vector = input_vector.normalized()
	
	# Handle mouse attacks
	if Input.is_action_just_pressed("attack1"):
		_execute_attack1()
	elif Input.is_action_just_pressed("attack2"):
		_execute_attack2()

func take_damage(damage: int):
	if not is_alive:
		return
	
	current_health -= damage
	_update_health_display()
	
	if current_health <= 0:
		current_health = 0
		is_alive = false
		_die()
	else:
		current_state = "taking_damage"
		_update_animation()
		# Reset damage state after a short time
		await get_tree().create_timer(0.3).timeout
		if current_state == "taking_damage":
			current_state = "idle"
			_update_animation()

func _die():
	"""Knight死亡处理"""
	current_state = "defeated"
	_update_animation()
	
	# 禁用输入和移动
	set_physics_process(false)
	
	# 播放死亡动画
	if animated_sprite:
		animated_sprite.play("defeat")
		# 等待死亡动画播放完成
		await animated_sprite.animation_finished
	
	# 调用基础类的死亡完成处理
	_on_death_complete()

func _on_death_complete():
	"""Knight死亡完成后的特殊处理"""
	print("Knight has fallen in battle!")
	# 可以在这里添加Knight特有的死亡效果

func heal(amount: int):
	if not is_alive:
		return
	
	current_health = min(current_health + amount, max_health)
	_update_health_display()

func use_skill(skill_name: String):
	if skill_name in skills:
		# Check cooldown
		if skill_name in skill_cooldowns:
			if skill_cooldowns[skill_name] > 0:
				return false
		
		# Execute skill
		match skill_name:
			"basic_attack":
				current_state = "attacking"
				_update_animation()
				# Reset attack state after a short time
				await get_tree().create_timer(0.5).timeout
				if current_state == "attacking":
					current_state = "idle"
					_update_animation()
			"shield_bash":
				_execute_shield_bash()
			"battle_cry":
				_execute_battle_cry()
		
		# Set cooldown
		if skill_name in skill_cooldowns:
			match skill_name:
				"shield_bash":
					skill_cooldowns[skill_name] = 3.0  # 3 second cooldown
				"battle_cry":
					skill_cooldowns[skill_name] = 8.0  # 8 second cooldown
		
		return true
	return false

func _execute_special_skill():
	# Warrior's special skill: Shield Bash
	if Input.is_action_just_pressed("skill_1"):
		use_skill("shield_bash")
	elif Input.is_action_just_pressed("skill_2"):
		use_skill("battle_cry")

func _execute_shield_bash():
	# Shield Bash: High damage melee attack with knockback
	print("Warrior uses Shield Bash!")
	attack_damage = 50  # Temporary damage boost
	current_state = "attacking"
	_update_animation()
	
	# Reset damage after attack
	await get_tree().create_timer(0.5).timeout
	attack_damage = 35
	if current_state == "attacking":
		current_state = "idle"
		_update_animation()

func _execute_battle_cry():
	# Battle Cry: Buffs attack damage and movement speed
	print("Warrior uses Battle Cry!")
	attack_damage += 15
	movement_speed += 50
	
	# Reset after 5 seconds
	await get_tree().create_timer(5.0).timeout
	attack_damage = 35
	movement_speed = 180.0

func _execute_attack1():
	# Left click attack: Basic slash with melee collision detection
	if current_state != "attacking" and current_state != "taking_damage" and current_state != "defeated":
		print("Knight uses Attack 1: Slash!")
		
		# Set state to attacking and play animation
		current_state = "attacking"
		_update_animation()
		
		# Play attack1 animation
		if animated_sprite and animated_sprite.sprite_frames.has_animation("attack1"):
			animated_sprite.play("attack1")
		
		# Wait a short delay before enabling collision detection
		await get_tree().create_timer(0.2).timeout
		
		# Enable attack collision shape
		if atk_collision_shape:
			atk_collision_shape.disabled = false
		
		# Get all bodies overlapping with AttackArea and damage them
		var overlapping_bodies = attack_area.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.has_method("take_damage"):
				body.take_damage(attack_damage)
				print("Knight hit ", body.name, " for ", attack_damage, " damage!")
		
		# Immediately disable collision shape after check
		if atk_collision_shape:
			atk_collision_shape.disabled = true
		
		# Wait for attack animation to finish
		await get_tree().create_timer(0.4).timeout
		
		# Reset state to idle
		if current_state == "attacking":
			current_state = "idle"
			_update_animation()

func _execute_attack2():
	# Right click attack: Heavy strike with melee collision detection
	if current_state != "attacking" and current_state != "taking_damage" and current_state != "defeated":
		print("Knight uses Attack 2: Heavy Strike!")
		
		# Set state to attacking and play animation
		current_state = "attacking"
		_update_animation()
		
		# Play attack2 animation
		if animated_sprite and animated_sprite.sprite_frames.has_animation("attack2"):
			animated_sprite.play("attack2")
		
		# Wait a short delay before enabling collision detection
		await get_tree().create_timer(0.3).timeout
		
		# Enable attack collision shape
		if atk_collision_shape:
			atk_collision_shape.disabled = false
		
		# Get all bodies overlapping with AttackArea and damage them
		var overlapping_bodies = attack_area.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.has_method("take_damage"):
				body.take_damage(attack_damage * 1.5)  # Heavy strike does 1.5x damage
				print("Knight hit ", body.name, " for ", attack_damage * 1.5, " damage!")
		
		# Immediately disable collision shape after check
		if atk_collision_shape:
			atk_collision_shape.disabled = true
		
		# Wait for attack animation to finish
		await get_tree().create_timer(0.5).timeout
		
		# Reset state to idle
		if current_state == "attacking":
			current_state = "idle"
			_update_animation()

func get_character_info() -> Dictionary:
	return {
		"name": character_name,
		"max_health": max_health,
		"current_health": current_health,
		"movement_speed": movement_speed,
		"attack_damage": attack_damage,
		"attack_style": attack_style,
		"skills": skills,
		"is_alive": is_alive,
		"current_state": current_state
	} 
