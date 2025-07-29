extends Node2D

var current_character: CharacterBody2D
var selected_character_type: String = ""

func _ready():
	# Connect back button
	$UI/BackButton.pressed.connect(_on_back_button_pressed)
	
	# Connect language change signal
	LanguageManager.language_changed.connect(_update_ui_text)
	
	# Connect Global signals
	Global.character_selected.connect(_on_character_selected)
	Global.game_state_changed.connect(_on_game_state_changed)
	
	# Spawn the selected character from Global
	spawn_character(Global.selected_character)
	
	# Initialize UI text
	_update_ui_text()
	
	# Change game state
	Global.change_game_state(Global.GameState.PLAYING)
	
	# Add test damage button
	_add_test_controls()

func _add_test_controls():
	"""添加测试控制按钮"""
	var test_panel = Panel.new()
	test_panel.name = "TestPanel"
	test_panel.position = Vector2(10, 10)
	test_panel.size = Vector2(200, 100)
	
	var vbox = VBoxContainer.new()
	test_panel.add_child(vbox)
	
	# 测试伤害按钮
	var damage_button = Button.new()
	damage_button.text = "Test Damage (20)"
	damage_button.pressed.connect(_test_damage)
	vbox.add_child(damage_button)
	
	# 测试死亡按钮
	var death_button = Button.new()
	death_button.text = "Test Death (100)"
	death_button.pressed.connect(_test_death)
	vbox.add_child(death_button)
	
	# 治疗按钮
	var heal_button = Button.new()
	heal_button.text = "Heal (50)"
	heal_button.pressed.connect(_test_heal)
	vbox.add_child(heal_button)
	
	add_child(test_panel)

func _test_damage():
	"""测试伤害功能"""
	if current_character and current_character.has_method("take_damage"):
		current_character.take_damage(20)
		print("Applied 20 damage to character")

func _test_death():
	"""测试死亡功能"""
	if current_character and current_character.has_method("take_damage"):
		current_character.take_damage(100)
		print("Applied 100 damage to character (should cause death)")

func _test_heal():
	"""测试治疗功能"""
	if current_character and current_character.has_method("heal"):
		current_character.heal(50)
		print("Healed character by 50")
	


func spawn_character(character_type: String):
	selected_character_type = character_type
	
	# Remove existing character if any
	if current_character:
		current_character.queue_free()
	
	# Load and spawn the selected character
	var character_scene: PackedScene
	match character_type:
		"Knight":
			character_scene = preload("res://characters/Knight.tscn")
		"Wizard":
			character_scene = preload("res://characters/Wizard.tscn")
		"Swordsman":
			character_scene = preload("res://characters/Swordsman.tscn")
		"Priest":
			character_scene = preload("res://characters/Priest.tscn")
		"Skeleton":
			character_scene = preload("res://characters/Skeleton.tscn")
		"Archer":
			character_scene = preload("res://characters/Archer.tscn")
		"Werewolf":
			character_scene = preload("res://characters/Werewolf.tscn")
		"Slime":
			character_scene = preload("res://characters/Slime.tscn")
		"Soldier":
			character_scene = preload("res://characters/Soldier.tscn")
		"ArmoredAxeman":
			character_scene = preload("res://characters/ArmoredAxeman.tscn")
		"EliteOrc":
			character_scene = preload("res://characters/EliteOrc.tscn")
		"KnightTemplar":
			character_scene = preload("res://characters/KnightTemplar.tscn")
		"Lancer":
			character_scene = preload("res://characters/Lancer.tscn")
		"ArmoredOrc":
			character_scene = preload("res://characters/ArmoredOrc.tscn")
		"ArmoredSkeleton":
			character_scene = preload("res://characters/ArmoredSkeleton.tscn")
		"GreatswordSkeleton":
			character_scene = preload("res://characters/GreatswordSkeleton.tscn")
		"Orc":
			character_scene = preload("res://characters/Orc.tscn")
		"OrcRider":
			character_scene = preload("res://characters/OrcRider.tscn")
		_:
			character_scene = preload("res://characters/Knight.tscn")
	
	if character_scene:
		current_character = character_scene.instantiate()
		add_child(current_character)
		current_character.global_position = Vector2(640, 360)  # Center of screen

func _process(delta):
	if current_character:
		_update_ui()

func _update_ui():
	if current_character and current_character.has_method("get_character_info"):
		var info = current_character.get_character_info()
		$UI/CharacterInfo/HealthLabel.text = "%s: %d/%d" % [LanguageManager.get_text("health"), info.current_health, info.max_health]
		$UI/CharacterInfo/StateLabel.text = "%s: %s" % [LanguageManager.get_text("state"), info.current_state]

func _update_ui_text():
	# Update all UI text based on current language
	$UI/CharacterInfo/ControlsLabel.text = LanguageManager.get_text("controls")
	$UI/CharacterInfo/MovementLabel.text = LanguageManager.get_text("move")
	$UI/CharacterInfo/AttackLabel.text = LanguageManager.get_text("jump")
	$UI/CharacterInfo/MouseAttack1Label.text = LanguageManager.get_text("attack1")
	$UI/CharacterInfo/MouseAttack2Label.text = LanguageManager.get_text("attack2")
	$UI/CharacterInfo/Skill1Label.text = LanguageManager.get_text("skill1")
	$UI/CharacterInfo/Skill2Label.text = LanguageManager.get_text("skill2")
	$UI/BackButton.text = LanguageManager.get_text("back_to_menu")

func _on_character_selected(character_name: String):
	print("Character selected in game: ", character_name)

func _on_game_state_changed(new_state: Global.GameState):
	print("Game state changed to: ", new_state)

func _on_back_button_pressed():
	# Reset selections and go back to main menu
	Global.reset_selections()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _input(event):
	# Handle character skill inputs
	if current_character and current_character.has_method("_execute_special_skill"):
		if event.is_action_pressed("skill_1"):
			current_character._execute_special_skill()
		elif event.is_action_pressed("skill_2"):
			current_character._execute_special_skill()
		elif event.is_action_pressed("skill_3"):
			current_character._execute_special_skill() 
