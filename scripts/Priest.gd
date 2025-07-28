extends CharacterBody2D

# Character Stats
@export var character_name: String = "Priest"
@export var max_health: int = 120
@export var movement_speed: float = 160.0
@export var attack_damage: int = 25
@export var attack_style: String = "magic"
@export var attack_range: float = 100.0

# Skills
@export var skills: Array[String] = ["basic_attack", "heal", "blessing"]
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

func _ready():
	current_health = max_health
	_setup_state_machine()
	_setup_health_bar()
	_update_health_display()
	
	# Set Priest-specific stats
	character_name = "Priest"
	max_health = 120
	movement_speed = 160.0
	attack_damage = 25
	attack_style = "magic"
	attack_range = 100.0
	
	# Priest skills
	skills = ["basic_attack", "heal", "blessing"]
	skill_cooldowns = {
		"heal": 0.0,
		"blessing": 0.0
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
		print("Priest jumps!")
	
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
	# Left click attack: Holy Light
	if current_state != "attacking" and current_state != "taking_damage" and current_state != "defeated":
		print("Priest uses Attack 1: Holy Light!")
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
	# Right click attack: Divine Smite
	if current_state != "attacking" and current_state != "taking_damage" and current_state != "defeated":
		print("Priest uses Attack 2: Divine Smite!")
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
			"heal":
				_execute_heal()
			"blessing":
				_execute_blessing()
		
		# Set cooldown
		if skill_name in skill_cooldowns:
			match skill_name:
				"heal":
					skill_cooldowns[skill_name] = 5.0  # 5 second cooldown
				"blessing":
					skill_cooldowns[skill_name] = 10.0  # 10 second cooldown
		
		return true
	return false

func _execute_special_skill():
	# Priest's special skills
	if Input.is_action_just_pressed("skill_1"):
		use_skill("heal")
	elif Input.is_action_just_pressed("skill_2"):
		use_skill("blessing")

func _execute_heal():
	# Heal: Restore health to self
	print("Priest uses Heal!")
	if current_health < max_health:
		current_health = min(current_health + 30, max_health)
		_update_health_display()
		print("Health restored!")
	current_state = "attacking"
	_update_animation()
	
	# Reset after 1 second
	await get_tree().create_timer(1.0).timeout
	if current_state == "attacking":
		current_state = "idle"
		_update_animation()

func _execute_blessing():
	# Blessing: Temporary buff to attack damage
	print("Priest uses Blessing!")
	attack_damage += 15
	
	# Reset after 8 seconds
	await get_tree().create_timer(8.0).timeout
	attack_damage = 25

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