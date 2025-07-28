extends CharacterBody2D

# Character Stats
@export var character_name: String = "Swordsman"
@export var max_health: int = 120
@export var movement_speed: float = 200.0
@export var attack_damage: int = 40
@export var attack_style: String = "ranged"
@export var attack_range: float = 150.0

# Skills
@export var skills: Array[String] = ["basic_attack", "multi_shot", "precise_shot"]
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
	
	# Set Swordsman-specific stats
	character_name = "Swordsman"
	max_health = 120
	movement_speed = 200.0
	attack_damage = 40
	attack_style = "melee"
	attack_range = 80.0
	
	# Swordsman skills
	skills = ["basic_attack", "quick_slash", "defensive_stance"]
	skill_cooldowns = {
		"quick_slash": 0.0,
		"defensive_stance": 0.0
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
		print("Swordsman jumps!")
	
	# Check if landed
	if is_on_floor():
		is_jumping = false
		can_jump = true
	
	move_and_slide()

func _update_state():
	if current_state == "defeated":
		return
	
	if current_state == "attacking":
		# Stay in attacking state for a short time
		return
	
	if current_state == "taking_damage":
		# Stay in damage state for a short time
		return
	
	# Handle jumping state
	if is_jumping:
		current_state = "jumping"
		_update_animation()
		return
	
	# Determine new state based on input
	var new_state = "idle"
	if input_vector != Vector2.ZERO:
		if Input.is_key_pressed(KEY_SHIFT):
			new_state = "running"
		else:
			new_state = "walking"
	
	# Update state and animation
	if new_state != current_state:
		current_state = new_state
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
		current_state = "defeated"
		_update_animation()
	else:
		current_state = "taking_damage"
		_update_animation()
		# Reset damage state after a short time
		await get_tree().create_timer(0.3).timeout
		if current_state == "taking_damage":
			current_state = "idle"
			_update_animation()

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
			"quick_slash":
				_execute_quick_slash()
			"defensive_stance":
				_execute_defensive_stance()
		
		return true
	return false

func _execute_quick_slash():
	if current_state != "attacking" and current_state != "taking_damage" and current_state != "defeated":
		print("Swordsman uses Quick Slash!")
		current_state = "attacking"
		_update_animation()
		# Play attack1 animation
		if animated_sprite and animated_sprite.sprite_frames.has_animation("attack1"):
			animated_sprite.play("attack1")
		await get_tree().create_timer(0.4).timeout
		if current_state == "attacking":
			current_state = "idle"
			_update_animation()

func _execute_defensive_stance():
	if current_state != "attacking" and current_state != "taking_damage" and current_state != "defeated":
		print("Swordsman uses Defensive Stance!")
		current_state = "attacking"
		_update_animation()
		# Play attack2 animation
		if animated_sprite and animated_sprite.sprite_frames.has_animation("attack2"):
			animated_sprite.play("attack2")
		await get_tree().create_timer(0.6).timeout
		if current_state == "attacking":
			current_state = "idle"
			_update_animation()

func _execute_attack1():
	# Left click attack: Quick slash
	if current_state != "attacking" and current_state != "taking_damage" and current_state != "defeated":
		print("Swordsman uses Attack 1: Quick Slash!")
		current_state = "attacking"
		_update_animation()
		# Play attack1 animation
		if animated_sprite and animated_sprite.sprite_frames.has_animation("attack1"):
			animated_sprite.play("attack1")
		await get_tree().create_timer(0.4).timeout
		if current_state == "attacking":
			current_state = "idle"
			_update_animation()

func _execute_attack2():
	# Right click attack: Defensive strike
	if current_state != "attacking" and current_state != "taking_damage" and current_state != "defeated":
		print("Swordsman uses Attack 2: Defensive Strike!")
		current_state = "attacking"
		_update_animation()
		# Play attack2 animation
		if animated_sprite and animated_sprite.sprite_frames.has_animation("attack2"):
			animated_sprite.play("attack2")
		await get_tree().create_timer(0.6).timeout
		if current_state == "attacking":
			current_state = "idle"
			_update_animation()

func get_character_info() -> Dictionary:
	return {
		"name": character_name,
		"current_health": current_health,
		"max_health": max_health,
		"movement_speed": movement_speed,
		"attack_damage": attack_damage,
		"attack_style": attack_style,
		"current_state": current_state,
		"is_alive": is_alive
	} 