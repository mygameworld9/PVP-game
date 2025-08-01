extends CharacterBody2D

# Character Stats
@export var character_name: String = "Archer"
@export var max_health: int = 120
@export var movement_speed: float = 200.0
@export var attack_damage: int = 25
@export var attack_style: String = "ranged"
@export var attack_range: float = 150.0

# Skills
@export var skills: Array[String] = ["quick_shot", "precise_shot", "rapid_fire"]
@export var skill_cooldowns: Dictionary = {}

# Current Stats
var current_health: int
var is_alive: bool = true
var character_type: String = ""

# State Machine
@onready var state_machine: Node = $StateMachine

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
	
	# Set Archer-specific stats
	character_name = "Archer"
	max_health = 120
	movement_speed = 200.0
	attack_damage = 25
	attack_style = "ranged"
	attack_range = 150.0
	
	# Archer skills
	skills = ["quick_shot", "precise_shot", "rapid_fire"]
	skill_cooldowns = {
		"precise_shot": 0.0,
		"rapid_fire": 0.0
	}
	
	# Update current health after setting max_health
	current_health = max_health
	_update_health_display()

func _setup_state_machine():
	# Connect state machine signal
	if state_machine:
		state_machine.state_changed.connect(_on_state_changed)

func _on_state_changed(new_state: String, old_state: String):
	# Handle state changes and play appropriate animations
	if animated_sprite:
		match new_state:
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
				animated_sprite.play("hurt")
			"defeated":
				animated_sprite.play("defeat")

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
	if not is_multiplayer_authority():
		return
	_handle_input()
	
	# Update state based on input
	_update_state()
	
	# Apply gravity
	velocity.y += gravity * delta
	
	# Apply movement
	if input_vector != Vector2.ZERO:
		velocity.x = input_vector.x * movement_speed
		facing_direction = input_vector.normalized()
		
		# Update sprite direction based on movement
		if animated_sprite:
			if input_vector.x > 0:
				animated_sprite.flip_h = false  # Face right
			elif input_vector.x < 0:
				animated_sprite.flip_h = true   # Face left
	else:
		velocity.x = 0
	
	# Handle jumping
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = jump_force
		is_jumping = true
		can_jump = false
		print("Archer jumps!")
	
	# Check if landed
	if is_on_floor():
		is_jumping = false
		can_jump = true
	
	move_and_slide()

func _update_state():
	# 如果角色正在攻击、受伤或已倒下，则不要根据移动来更新状态
	var current_state = state_machine.get_current_state()
	if current_state == "attacking" or current_state == "taking_damage" or current_state == "defeated":
		return # 提前退出函数，不执行下面的逻辑

	if is_jumping:
		state_machine.transition_to("jumping")
		return
	
	if input_vector != Vector2.ZERO:
		if abs(input_vector.x) > 0.5:
			state_machine.transition_to("walking")
		else:
			state_machine.transition_to("idle")
	else:
		state_machine.transition_to("idle")

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
		state_machine.transition_to("taking_damage")
		# Reset damage state after a short time
		await get_tree().create_timer(0.3).timeout
		if state_machine.get_current_state() == "taking_damage":
			state_machine.transition_to("idle")

func _die():
	"""Archer死亡处理"""
	state_machine.transition_to("defeated")
	
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
	"""Archer死亡完成后的特殊处理"""
	print("Archer has fallen in battle!")
	# 可以在这里添加Archer特有的死亡效果

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
			"quick_shot":
				state_machine.transition_to("attacking")
				# Reset attack state after a short time
				await get_tree().create_timer(0.5).timeout
				if state_machine.get_current_state() == "attacking":
					state_machine.transition_to("idle")
			"precise_shot":
				_execute_precise_shot()
			"rapid_fire":
				_execute_rapid_fire()
		
		# Set cooldown
		if skill_name in skill_cooldowns:
			match skill_name:
				"precise_shot":
					skill_cooldowns[skill_name] = 2.0  # 2 second cooldown
				"rapid_fire":
					skill_cooldowns[skill_name] = 5.0  # 5 second cooldown
		
		return true
	return false

func _execute_special_skill():
	# Archer's special skill: Precise Shot
	if Input.is_action_just_pressed("skill_1"):
		use_skill("precise_shot")
	elif Input.is_action_just_pressed("skill_2"):
		use_skill("rapid_fire")

func _execute_precise_shot():
	# Precise Shot: High damage single shot
	print("Archer uses Precise Shot!")
	attack_damage = 40  # Temporary damage boost
	state_machine.transition_to("attacking")
	
	# Reset damage after attack
	await get_tree().create_timer(0.5).timeout
	attack_damage = 25
	if state_machine.get_current_state() == "attacking":
		state_machine.transition_to("idle")

func _execute_rapid_fire():
	# Rapid Fire: Multiple quick shots
	print("Archer uses Rapid Fire!")
	attack_damage = 15  # Lower damage but multiple hits
	state_machine.transition_to("attacking")
	
	# Reset after 3 seconds
	await get_tree().create_timer(3.0).timeout
	attack_damage = 25

func _execute_attack1():
	# Left click attack: Quick Shot with melee collision detection
	var current_state = state_machine.get_current_state()
	if current_state != "attacking" and current_state != "taking_damage" and current_state != "defeated":
		print("Archer uses Attack 1: Quick Shot!")
		
		# Set state to attacking
		state_machine.transition_to("attacking")
		
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
				print("Archer hit ", body.name, " for ", attack_damage, " damage!")
		
		# Immediately disable collision shape after check
		if atk_collision_shape:
			atk_collision_shape.disabled = true
		
		# Wait for attack animation to finish
		await get_tree().create_timer(0.4).timeout
		
		# Reset state to idle
		if state_machine.get_current_state() == "attacking":
			state_machine.transition_to("idle")

func _execute_attack2():
	# Right click attack: Precise Shot with melee collision detection
	var current_state = state_machine.get_current_state()
	if current_state != "attacking" and current_state != "taking_damage" and current_state != "defeated":
		print("Archer uses Attack 2: Precise Shot!")
		
		# Set state to attacking
		state_machine.transition_to("attacking")
		
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
				body.take_damage(attack_damage * 1.5)  # Precise shot does 1.5x damage
				print("Archer hit ", body.name, " for ", attack_damage * 1.5, " damage!")
		
		# Immediately disable collision shape after check
		if atk_collision_shape:
			atk_collision_shape.disabled = true
		
		# Wait for attack animation to finish
		await get_tree().create_timer(0.5).timeout
		
		# Reset state to idle
		if state_machine.get_current_state() == "attacking":
			state_machine.transition_to("idle")

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
		"current_state": state_machine.get_current_state()
	} 
