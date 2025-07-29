extends CharacterBody2D

# Character Stats
@export var character_name: String = "Slime"
@export var max_health: int = 130
@export var movement_speed: float = 140.0
@export var attack_damage: int = 20
@export var attack_style: String = "acid"
@export var attack_range: float = 60.0

# Skills
@export var skills: Array[String] = ["basic_attack", "acid_spray", "split"]
@export var skill_cooldowns: Dictionary = {}

# Current Stats
var current_health: int
var is_alive: bool = true

# State Machine
var current_state: String = "idle"

# Components
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar

# Movement
var input_vector: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.RIGHT

# Jumping
var jump_force: float = -400.0
var gravity: float = 980.0
var is_jumping: bool = false
var can_jump: bool = true

# Slime-specific properties
var is_split: bool = false

func _ready():
	current_health = max_health
	_setup_state_machine()
	_setup_health_bar()
	_update_health_display()
	_setup_collision_layers()
	
	# Set Slime-specific stats
	character_name = "Slime"
	max_health = 130
	movement_speed = 140.0
	attack_damage = 20
	attack_style = "acid"
	attack_range = 60.0
	
	# Slime skills
	skills = ["basic_attack", "acid_spray", "split"]
	skill_cooldowns = {
		"acid_spray": 0.0,
		"split": 0.0
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
		print("Slime jumps!")
	
	# Check if landed
	if is_on_floor():
		is_jumping = false
		can_jump = true
	
	move_and_slide()

func _handle_input():
	input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	input_vector = input_vector.normalized()

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
			"jumping":
				animated_sprite.play("idle") # Placeholder for jump animation
			"attacking":
				animated_sprite.play("attack1")
			"taking_damage":
				animated_sprite.play("hurt")
			"defeated":
				animated_sprite.play("defeat")

func _input(event):
	# Handle mouse attacks
	if event.is_action_pressed("attack1"):
		_execute_attack1()
	elif event.is_action_pressed("attack2"):
		_execute_attack2()

func _execute_attack1():
	# Left click attack: Acid Bite
	if current_state != "attacking" and current_state != "taking_damage" and current_state != "defeated":
		print("Slime uses Attack 1: Acid Bite!")
		current_state = "attacking"
		_update_animation()
		# Play attack1 animation
		if animated_sprite and animated_sprite.sprite_frames.has_animation("attack1"):
			animated_sprite.play("attack1")
		await get_tree().create_timer(0.6).timeout
		if current_state == "attacking":
			current_state = "idle"
			_update_animation()

func _execute_attack2():
	# Right click attack: Blob Slam
	if current_state != "attacking" and current_state != "taking_damage" and current_state != "defeated":
		print("Slime uses Attack 2: Blob Slam!")
		current_state = "attacking"
		_update_animation()
		# Play attack2 animation
		if animated_sprite and animated_sprite.sprite_frames.has_animation("attack2"):
			animated_sprite.play("attack2")
		await get_tree().create_timer(0.8).timeout
		if current_state == "attacking":
			current_state = "idle"
			_update_animation()

func take_damage(damage: int):
	if current_state != "defeated":
		current_health -= damage
		_update_health_display()
		
		if current_health <= 0:
			current_health = 0
			is_alive = false
			current_state = "defeated"
			_update_animation()
		else:
			current_state = "taking_damage"
			_update_animation()
			await get_tree().create_timer(0.5).timeout
			if current_state == "taking_damage":
				current_state = "idle"
				_update_animation()

func use_skill(skill_name: String) -> bool:
	if skill_name in skills and skill_cooldowns.get(skill_name, 0.0) <= 0.0:
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
			"acid_spray":
				_execute_acid_spray()
			"split":
				_execute_split()
		
		# Set cooldown
		if skill_name in skill_cooldowns:
			match skill_name:
				"acid_spray":
					skill_cooldowns[skill_name] = 5.0  # 5 second cooldown
				"split":
					skill_cooldowns[skill_name] = 12.0  # 12 second cooldown
		
		return true
	return false

func _execute_special_skill():
	# Slime's special skills
	if Input.is_action_just_pressed("skill_1"):
		use_skill("acid_spray")
	elif Input.is_action_just_pressed("skill_2"):
		use_skill("split")

func _execute_acid_spray():
	# Acid Spray: Area damage attack
	print("Slime uses Acid Spray!")
	attack_damage = 35  # Temporary damage boost
	current_state = "attacking"
	_update_animation()
	
	# Reset damage after attack
	await get_tree().create_timer(0.5).timeout
	attack_damage = 20
	if current_state == "attacking":
		current_state = "idle"
		_update_animation()

func _execute_split():
	# Split: Divide into smaller slimes for increased speed
	print("Slime uses Split!")
	is_split = true
	movement_speed += 80
	animated_sprite.modulate = Color(0.5, 1.0, 0.5, 1) # Green tint
	
	# Reset after 8 seconds
	await get_tree().create_timer(8.0).timeout
	is_split = false
	movement_speed = 140.0
	animated_sprite.modulate = Color(1, 1, 1, 1)

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