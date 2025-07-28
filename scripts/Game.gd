extends Node2D

var current_character: CharacterBody2D
var selected_character_type: String = ""

func _ready():
	# Connect back button
	$UI/BackButton.pressed.connect(_on_back_button_pressed)
	
	# Connect language change signal
	LanguageManager.language_changed.connect(_update_ui_text)
	
	# Spawn a default character (Knight) for testing
	spawn_character("Knight")
	
	# Initialize UI text
	_update_ui_text()

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
		"Armored Axeman":
			character_scene = preload("res://characters/ArmoredAxeman.tscn")
		"Elite Orc":
			character_scene = preload("res://characters/EliteOrc.tscn")
		"Knight Templar":
			character_scene = preload("res://characters/KnightTemplar.tscn")
		"Lancer":
			character_scene = preload("res://characters/Lancer.tscn")
		"Armored Orc":
			character_scene = preload("res://characters/ArmoredOrc.tscn")
		"Armored Skeleton":
			character_scene = preload("res://characters/ArmoredSkeleton.tscn")
		"Greatsword Skeleton":
			character_scene = preload("res://characters/GreatswordSkeleton.tscn")
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

func _on_back_button_pressed():
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
