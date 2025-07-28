extends Control

var selected_character: String = ""
var character_scene: PackedScene

func _ready():
	# Connect button signals
	$CharacterList/KnightBtn.pressed.connect(_on_knight_selected)
	$CharacterList/WizardBtn.pressed.connect(_on_wizard_selected)
	$CharacterList/SwordsmanBtn.pressed.connect(_on_swordsman_selected)
	$CharacterList/PriestBtn.pressed.connect(_on_priest_selected)
	$CharacterList/SkeletonBtn.pressed.connect(_on_skeleton_selected)
	$CharacterList/ArcherBtn.pressed.connect(_on_archer_selected)
	$CharacterList/WerewolfBtn.pressed.connect(_on_werewolf_selected)
	$CharacterList/SlimeBtn.pressed.connect(_on_slime_selected)
	$CharacterList/SoldierBtn.pressed.connect(_on_soldier_selected)
	$CharacterList/ArmoredAxemanBtn.pressed.connect(_on_armored_axeman_selected)
	$CharacterList/EliteOrcBtn.pressed.connect(_on_elite_orc_selected)
	$CharacterList/KnightTemplarBtn.pressed.connect(_on_knight_templar_selected)
	$CharacterList/LancerBtn.pressed.connect(_on_lancer_selected)
	$CharacterList/ArmoredOrcBtn.pressed.connect(_on_armored_orc_selected)
	$CharacterList/ArmoredSkeletonBtn.pressed.connect(_on_armored_skeleton_selected)
	$CharacterList/GreatswordSkeletonBtn.pressed.connect(_on_greatsword_skeleton_selected)
	
	# Connect language buttons
	$LanguageContainer/EnglishBtn.pressed.connect(_on_english_selected)
	$LanguageContainer/ChineseBtn.pressed.connect(_on_chinese_selected)
	
	# Connect language change signal
	LanguageManager.language_changed.connect(_update_ui_text)
	
	# Initialize UI text
	_update_ui_text()

func _on_knight_selected():
	selected_character = "Knight"
	$StatusLabel.text = LanguageManager.get_text("knight_selected")
	character_scene = preload("res://characters/Knight.tscn")

func _on_wizard_selected():
	selected_character = "Wizard"
	$StatusLabel.text = LanguageManager.get_text("wizard_selected")
	character_scene = preload("res://characters/Wizard.tscn")

func _on_swordsman_selected():
	selected_character = "Swordsman"
	$StatusLabel.text = LanguageManager.get_text("swordsman_selected")
	character_scene = preload("res://characters/Swordsman.tscn")

func _on_priest_selected():
	selected_character = "Priest"
	$StatusLabel.text = LanguageManager.get_text("priest_selected")
	character_scene = preload("res://characters/Priest.tscn")

func _on_skeleton_selected():
	selected_character = "Skeleton"
	$StatusLabel.text = LanguageManager.get_text("skeleton_selected")
	character_scene = preload("res://characters/Skeleton.tscn")

func _on_archer_selected():
	selected_character = "Archer"
	$StatusLabel.text = LanguageManager.get_text("archer_selected")
	character_scene = preload("res://characters/Archer.tscn")

func _on_werewolf_selected():
	selected_character = "Werewolf"
	$StatusLabel.text = LanguageManager.get_text("werewolf_selected")
	character_scene = preload("res://characters/Werewolf.tscn")

func _on_slime_selected():
	selected_character = "Slime"
	$StatusLabel.text = LanguageManager.get_text("slime_selected")
	character_scene = preload("res://characters/Slime.tscn")

func _on_soldier_selected():
	selected_character = "Soldier"
	$StatusLabel.text = LanguageManager.get_text("soldier_selected")
	character_scene = preload("res://characters/Soldier.tscn")

func _on_armored_axeman_selected():
	selected_character = "Armored Axeman"
	$StatusLabel.text = LanguageManager.get_text("armored_axeman_selected")
	character_scene = preload("res://characters/ArmoredAxeman.tscn")

func _on_elite_orc_selected():
	selected_character = "Elite Orc"
	$StatusLabel.text = LanguageManager.get_text("elite_orc_selected")
	character_scene = preload("res://characters/EliteOrc.tscn")

func _on_knight_templar_selected():
	selected_character = "Knight Templar"
	$StatusLabel.text = LanguageManager.get_text("knight_templar_selected")
	character_scene = preload("res://characters/KnightTemplar.tscn")

func _on_lancer_selected():
	selected_character = "Lancer"
	$StatusLabel.text = LanguageManager.get_text("lancer_selected")
	character_scene = preload("res://characters/Lancer.tscn")

func _on_armored_orc_selected():
	selected_character = "Armored Orc"
	$StatusLabel.text = LanguageManager.get_text("armored_orc_selected")
	character_scene = preload("res://characters/ArmoredOrc.tscn")

func _on_armored_skeleton_selected():
	selected_character = "Armored Skeleton"
	$StatusLabel.text = LanguageManager.get_text("armored_skeleton_selected")
	character_scene = preload("res://characters/ArmoredSkeleton.tscn")

func _on_greatsword_skeleton_selected():
	selected_character = "Greatsword Skeleton"
	$StatusLabel.text = LanguageManager.get_text("greatsword_skeleton_selected")
	character_scene = preload("res://characters/GreatswordSkeleton.tscn")

func _on_english_selected():
	LanguageManager.set_language("en")

func _on_chinese_selected():
	LanguageManager.set_language("zh")

func _update_ui_text():
	# Update all UI text based on current language
	$Title.text = LanguageManager.get_text("game_title")
	$CharacterList/KnightBtn.text = LanguageManager.get_text("knight")
	$CharacterList/WizardBtn.text = LanguageManager.get_text("wizard")
	$CharacterList/SwordsmanBtn.text = LanguageManager.get_text("swordsman")
	$CharacterList/PriestBtn.text = LanguageManager.get_text("priest")
	$CharacterList/SkeletonBtn.text = LanguageManager.get_text("skeleton")
	$CharacterList/ArcherBtn.text = LanguageManager.get_text("archer")
	$CharacterList/WerewolfBtn.text = LanguageManager.get_text("werewolf")
	$CharacterList/SlimeBtn.text = LanguageManager.get_text("slime")
	$CharacterList/SoldierBtn.text = LanguageManager.get_text("soldier")
	$CharacterList/ArmoredAxemanBtn.text = LanguageManager.get_text("armored_axeman")
	$CharacterList/EliteOrcBtn.text = LanguageManager.get_text("elite_orc")
	$CharacterList/KnightTemplarBtn.text = LanguageManager.get_text("knight_templar")
	$CharacterList/LancerBtn.text = LanguageManager.get_text("lancer")
	$CharacterList/ArmoredOrcBtn.text = LanguageManager.get_text("armored_orc")
	$CharacterList/ArmoredSkeletonBtn.text = LanguageManager.get_text("armored_skeleton")
	$CharacterList/GreatswordSkeletonBtn.text = LanguageManager.get_text("greatsword_skeleton")
	$LanguageContainer/LanguageLabel.text = LanguageManager.get_text("language")
	$LanguageContainer/EnglishBtn.text = LanguageManager.get_text("english")
	$LanguageContainer/ChineseBtn.text = LanguageManager.get_text("chinese")
	
	# Update status label if no character is selected
	if selected_character == "":
		$StatusLabel.text = LanguageManager.get_text("select_character")

func _input(event):
	if event.is_action_pressed("jump") and selected_character != "":
		_start_game()

func _start_game():
	if character_scene:
		var game_scene = preload("res://scenes/Game.tscn")
		get_tree().change_scene_to_file("res://scenes/Game.tscn") 
