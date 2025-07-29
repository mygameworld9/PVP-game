extends Control

func _ready():
	# Connect button signals
	$MapList/DefaultMapBtn.pressed.connect(_on_default_map_selected)
	$MapList/ForestMapBtn.pressed.connect(_on_forest_map_selected)
	$MapList/CastleMapBtn.pressed.connect(_on_castle_map_selected)
	$MapList/DungeonMapBtn.pressed.connect(_on_dungeon_map_selected)
	$MapList/ArenaMapBtn.pressed.connect(_on_arena_map_selected)
	$MapList/DesertMapBtn.pressed.connect(_on_desert_map_selected)
	$BackButton.pressed.connect(_on_back_button_pressed)
	
	# Connect Global signals
	Global.character_selected.connect(_on_character_selected)
	Global.map_selected.connect(_on_map_selected)
	
	# Connect language change signal
	LanguageManager.language_changed.connect(_update_ui_text)
	
	# Update UI
	_update_ui()
	_update_ui_text()
	
	# Change game state
	Global.change_game_state(Global.GameState.MAP_SELECTION)

func _update_ui():
	# Update character info
	$CharacterInfo.text = "Selected Character: " + Global.selected_character
	
	# Update status label
	if Global.selected_map != "":
		var map_info = Global.get_map_info(Global.selected_map)
		$StatusLabel.text = LanguageManager.get_text("map_selected")
	else:
		$StatusLabel.text = LanguageManager.get_text("select_map")

func _update_ui_text():
	# Update all UI text based on current language
	$Title.text = LanguageManager.get_text("select_map")
	$MapList/DefaultMapBtn.text = LanguageManager.get_text("training_grounds")
	$MapList/ForestMapBtn.text = LanguageManager.get_text("mystic_forest")
	$MapList/CastleMapBtn.text = LanguageManager.get_text("royal_castle")
	$MapList/DungeonMapBtn.text = LanguageManager.get_text("dark_dungeon")
	$MapList/ArenaMapBtn.text = LanguageManager.get_text("battle_arena")
	$MapList/DesertMapBtn.text = LanguageManager.get_text("desert_oasis")
	$BackButton.text = LanguageManager.get_text("back_to_character_selection")

func _on_default_map_selected():
	Global.select_map("DefaultMap")
	$StatusLabel.text = "Map selected: Training Grounds"

func _on_forest_map_selected():
	Global.select_map("ForestMap")
	$StatusLabel.text = "Map selected: Mystic Forest"

func _on_castle_map_selected():
	Global.select_map("CastleMap")
	$StatusLabel.text = "Map selected: Royal Castle"

func _on_dungeon_map_selected():
	Global.select_map("DungeonMap")
	$StatusLabel.text = "Map selected: Dark Dungeon"

func _on_arena_map_selected():
	Global.select_map("ArenaMap")
	$StatusLabel.text = "Map selected: Battle Arena"

func _on_desert_map_selected():
	Global.select_map("DesertMap")
	$StatusLabel.text = "Map selected: Desert Oasis"

func _on_back_button_pressed():
	# Go back to character selection
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_character_selected(character_name: String):
	_update_ui()

func _on_map_selected(map_name: String):
	_update_ui()

func _input(event):
	if event.is_action_pressed("jump") and Global.selected_map != "":
		# Start the game with selected character and map
		_start_game()

func _start_game():
	if Global.is_game_ready_to_start():
		print("Starting game with character: ", Global.selected_character)
		print("Starting game with map: ", Global.selected_map)
		
		# Change to game scene
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
	else:
		print("Game not ready to start - missing character or map selection") 