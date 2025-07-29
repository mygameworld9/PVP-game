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
	$CharacterList/OrcBtn.pressed.connect(_on_orc_selected)
	$CharacterList/OrcRiderBtn.pressed.connect(_on_orc_rider_selected)
	

	

	

	

	
	# Connect language buttons
	$LanguageContainer/EnglishBtn.pressed.connect(_on_english_selected)
	$LanguageContainer/ChineseBtn.pressed.connect(_on_chinese_selected)
	
	# Connect language change signal
	LanguageManager.language_changed.connect(_update_ui_text)
	
	# Connect Global signals
	Global.character_selected.connect(_on_character_selected)
	
	# Initialize UI text
	_update_ui_text()
	
	# Change game state
	Global.change_game_state(Global.GameState.CHARACTER_SELECTION)

func _on_knight_selected():
	Global.select_character("Knight")
	$StatusLabel.text = LanguageManager.get_text("knight_selected")
	character_scene = preload("res://characters/Knight.tscn")

func _on_wizard_selected():
	Global.select_character("Wizard")
	$StatusLabel.text = LanguageManager.get_text("wizard_selected")
	character_scene = preload("res://characters/Wizard.tscn")

func _on_swordsman_selected():
	Global.select_character("Swordsman")
	$StatusLabel.text = LanguageManager.get_text("swordsman_selected")
	character_scene = preload("res://characters/Swordsman.tscn")

func _on_priest_selected():
	Global.select_character("Priest")
	$StatusLabel.text = LanguageManager.get_text("priest_selected")
	character_scene = preload("res://characters/Priest.tscn")

func _on_skeleton_selected():
	Global.select_character("Skeleton")
	$StatusLabel.text = LanguageManager.get_text("skeleton_selected")
	character_scene = preload("res://characters/Skeleton.tscn")

func _on_archer_selected():
	Global.select_character("Archer")
	$StatusLabel.text = LanguageManager.get_text("archer_selected")
	character_scene = preload("res://characters/Archer.tscn")

func _on_werewolf_selected():
	Global.select_character("Werewolf")
	$StatusLabel.text = LanguageManager.get_text("werewolf_selected")
	character_scene = preload("res://characters/Werewolf.tscn")

func _on_slime_selected():
	Global.select_character("Slime")
	$StatusLabel.text = LanguageManager.get_text("slime_selected")
	character_scene = preload("res://characters/Slime.tscn")

func _on_soldier_selected():
	Global.select_character("Soldier")
	$StatusLabel.text = LanguageManager.get_text("soldier_selected")
	character_scene = preload("res://characters/Soldier.tscn")

func _on_armored_axeman_selected():
	Global.select_character("ArmoredAxeman")
	$StatusLabel.text = LanguageManager.get_text("armored_axeman_selected")
	character_scene = preload("res://characters/ArmoredAxeman.tscn")

func _on_elite_orc_selected():
	Global.select_character("EliteOrc")
	$StatusLabel.text = LanguageManager.get_text("elite_orc_selected")
	character_scene = preload("res://characters/EliteOrc.tscn")

func _on_knight_templar_selected():
	Global.select_character("KnightTemplar")
	$StatusLabel.text = LanguageManager.get_text("knight_templar_selected")
	character_scene = preload("res://characters/KnightTemplar.tscn")

func _on_lancer_selected():
	Global.select_character("Lancer")
	$StatusLabel.text = LanguageManager.get_text("lancer_selected")
	character_scene = preload("res://characters/Lancer.tscn")

func _on_armored_orc_selected():
	Global.select_character("ArmoredOrc")
	$StatusLabel.text = LanguageManager.get_text("armored_orc_selected")
	character_scene = preload("res://characters/ArmoredOrc.tscn")

func _on_armored_skeleton_selected():
	Global.select_character("ArmoredSkeleton")
	$StatusLabel.text = LanguageManager.get_text("armored_skeleton_selected")
	character_scene = preload("res://characters/ArmoredSkeleton.tscn")

func _on_greatsword_skeleton_selected():
	Global.select_character("GreatswordSkeleton")
	$StatusLabel.text = LanguageManager.get_text("greatsword_skeleton_selected")
	character_scene = preload("res://characters/GreatswordSkeleton.tscn")

func _on_orc_selected():
	Global.select_character("Orc")
	$StatusLabel.text = LanguageManager.get_text("orc_selected")
	character_scene = preload("res://characters/Orc.tscn")

func _on_orc_rider_selected():
	Global.select_character("OrcRider")
	$StatusLabel.text = LanguageManager.get_text("orc_rider_selected")
	character_scene = preload("res://characters/OrcRider.tscn")







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
	$CharacterList/OrcBtn.text = LanguageManager.get_text("orc")
	$CharacterList/OrcRiderBtn.text = LanguageManager.get_text("orc_rider")
	$LanguageContainer/LanguageLabel.text = LanguageManager.get_text("language")
	$LanguageContainer/EnglishBtn.text = LanguageManager.get_text("english")
	$LanguageContainer/ChineseBtn.text = LanguageManager.get_text("chinese")
	
	# Update status label if no character is selected
	if selected_character == "":
		$StatusLabel.text = LanguageManager.get_text("select_character")

func _input(event):
	if event.is_action_pressed("jump") and Global.selected_character != "":
		_start_game()
	# TEMP: Press 'L' to open lobby
	if event.is_action_pressed("ui_lobby"):
		_open_lobby()

func _start_game():
	if Global.selected_character != "":
		# Navigate directly to game
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
	else:
		print("No character selected")

func _on_character_selected(character_name: String):
	# Update local selected_character for compatibility
	selected_character = character_name 

func _open_lobby():
	get_tree().change_scene_to_file("res://scenes/Lobby.tscn")
	
