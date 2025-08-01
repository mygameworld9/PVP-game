extends CharacterBody2D

# Character Stats
@export var character_name: String = "Character"
@export var max_health: int = 100
@export var movement_speed: float = 200.0
@export var attack_damage: int = 20
@export var attack_style: String = "melee" # "melee", "ranged"
@export var attack_range: float = 50.0

# Skills
@export var skills: Array[String] = ["basic_attack", "special_skill"]
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
var is_jumping: bool = false

func _ready():
	current_health = max_health
	_setup_state_machine()
	_setup_health_bar()
	_update_health_display()
	_setup_collision_layers()

func _setup_state_machine():
	# Simple state management without complex inheritance
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
	if not is_multiplayer_authority():
		return
	# Handle movement input
	_handle_input()
	
	# Update state based on input
	_update_state()
	
	# Apply movement
	if input_vector != Vector2.ZERO:
		velocity = input_vector * movement_speed
		facing_direction = input_vector.normalized()
		
		# Update sprite direction based on movement
		if animated_sprite:
			if input_vector.x > 0:
				animated_sprite.flip_h = false  # Face right
			elif input_vector.x < 0:
				animated_sprite.flip_h = true   # Face left
	else:
		velocity = Vector2.ZERO
	
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

func _handle_input():
	# 如果角色已死亡，不处理输入
	if not is_alive:
		return
	
	input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	
	input_vector = input_vector.normalized()

func _update_animation():
	if animated_sprite:
		match current_state:
			"idle":
				animated_sprite.play("idle")
			"walking":
				animated_sprite.play("walk")
			"running":
				animated_sprite.play("run")
			"attacking":
				animated_sprite.play("attack")
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
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	
	input_vector = input_vector.normalized()

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
	"""处理角色死亡"""
	current_state = "defeated"
	_update_animation()
	
	# 禁用输入和移动
	set_physics_process(false)
	
	# 播放死亡动画
	if animated_sprite:
		animated_sprite.play("defeat")
		# 等待死亡动画播放完成
		await animated_sprite.animation_finished
	
	# 可选：在死亡后执行额外操作
	_on_death_complete()

func _on_death_complete():
	"""死亡完成后的回调，子类可以重写"""
	# 可以在这里添加死亡特效、音效等
	print(character_name + " has been defeated!")
	
	# 可选：延迟后销毁角色
	# await get_tree().create_timer(2.0).timeout
	# queue_free()

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
			"special_skill":
				_execute_special_skill()
		
		# Set cooldown
		if skill_name in skill_cooldowns:
			skill_cooldowns[skill_name] = 1.0  # 1 second cooldown
		
		return true
	return false

func _execute_special_skill():
	# Override in subclasses
	pass

func get_character_info() -> Dictionary:
	return {
		"name": character_name,
		"max_health": max_health,
		"current_health": current_health,
		"movement_speed": movement_speed,
		"attack_damage": attack_damage,
		"attack_style": attack_style,
		"skills": skills,
		"is_alive": is_alive
	} 
