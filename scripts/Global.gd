extends Node

# Game State Management
enum GameState {MENU, CHARACTER_SELECTION, MAP_SELECTION, PLAYING, PAUSED}

# Selected Character and Map
var selected_character: String = "Knight"
var selected_map: String = "DefaultMap"

# Available Characters and Maps
var available_characters: Array[String] = [
	"Knight", "Wizard", "Swordsman", "Priest", "Skeleton", 
	"Archer", "Werewolf", "Slime", "Soldier", "ArmoredAxeman",
	"EliteOrc", "KnightTemplar", "Lancer", "ArmoredOrc", 
	"ArmoredSkeleton", "GreatswordSkeleton", "Orc", "OrcRider"
]

var available_maps: Array[String] = [
	"DefaultMap", "ForestMap", "CastleMap", "DungeonMap", "ArenaMap", "DesertMap"
]

# Current Game State
var current_game_state: GameState = GameState.MENU

# Character and Map Data
var character_data: Dictionary = {
	"Knight": {"health": 150, "speed": 180, "damage": 35, "style": "melee"},
	"Wizard": {"health": 100, "speed": 160, "damage": 45, "style": "ranged"},
	"Swordsman": {"health": 120, "speed": 200, "damage": 40, "style": "melee"},
	"Priest": {"health": 90, "speed": 150, "damage": 30, "style": "ranged"},
	"Skeleton": {"health": 80, "speed": 180, "damage": 35, "style": "melee"},
	"Archer": {"health": 110, "speed": 220, "damage": 35, "style": "ranged"},
	"Werewolf": {"health": 130, "speed": 190, "damage": 45, "style": "melee"},
	"Slime": {"health": 70, "speed": 140, "damage": 25, "style": "melee"},
	"Soldier": {"health": 140, "speed": 170, "damage": 40, "style": "melee"},
	"ArmoredAxeman": {"health": 160, "speed": 150, "damage": 50, "style": "melee"},
	"EliteOrc": {"health": 180, "speed": 160, "damage": 55, "style": "melee"},
	"KnightTemplar": {"health": 170, "speed": 165, "damage": 45, "style": "melee"},
	"Lancer": {"health": 130, "speed": 185, "damage": 42, "style": "melee"},
	"ArmoredOrc": {"health": 190, "speed": 155, "damage": 60, "style": "melee"},
	"ArmoredSkeleton": {"health": 120, "speed": 175, "damage": 38, "style": "melee"},
	"GreatswordSkeleton": {"health": 140, "speed": 165, "damage": 48, "style": "melee"},
	"Orc": {"health": 160, "speed": 170, "damage": 45, "style": "melee"},
	"OrcRider": {"health": 150, "speed": 200, "damage": 50, "style": "melee"}
}

var map_data: Dictionary = {
	"DefaultMap": {"name": "Training Grounds", "difficulty": 1, "size": "small", "tileset": "training"},
	"ForestMap": {"name": "Mystic Forest", "difficulty": 2, "size": "medium", "tileset": "forest"},
	"CastleMap": {"name": "Royal Castle", "difficulty": 3, "size": "large", "tileset": "castle"},
	"DungeonMap": {"name": "Dark Dungeon", "difficulty": 4, "size": "medium", "tileset": "dungeon"},
	"ArenaMap": {"name": "Battle Arena", "difficulty": 5, "size": "large", "tileset": "arena"},
	"DesertMap": {"name": "Desert Oasis", "difficulty": 3, "size": "medium", "tileset": "desert"}
}

# Signals
signal character_selected(character_name: String)
signal map_selected(map_name: String)
signal game_state_changed(new_state: GameState)
signal game_ready_to_start()

# Functions
func _ready():
	_load_custom_maps()

func select_character(character_name: String):
	if character_name in available_characters:
		selected_character = character_name
		character_selected.emit(character_name)
		print("Character selected: ", character_name)

func select_map(map_name: String):
	if map_name in available_maps:
		selected_map = map_name
		map_selected.emit(map_name)
		print("Map selected: ", map_name)

func change_game_state(new_state: GameState):
	current_game_state = new_state
	game_state_changed.emit(new_state)
	print("Game state changed to: ", new_state)

func get_character_info(character_name: String) -> Dictionary:
	if character_name in character_data:
		return character_data[character_name]
	return {}

func get_map_info(map_name: String) -> Dictionary:
	if map_name in map_data:
		return map_data[map_name]
	return {}

func is_game_ready_to_start() -> bool:
	return selected_character != "" and selected_map != ""

func reset_selections():
	selected_character = "Knight"
	selected_map = "DefaultMap"
	current_game_state = GameState.MENU

func _load_custom_maps():
	# 扫描user://目录下的地图文件
	var dir = DirAccess.open("user://")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".dat"):
				var map_name = file_name.replace(".dat", "")
				var custom_map_name = "Custom_" + map_name
				
				# 添加到可用地图列表
				if custom_map_name not in available_maps:
					available_maps.append(custom_map_name)
				
				# 添加到地图数据
				map_data[custom_map_name] = {
					"name": "Custom " + map_name,
					"difficulty": 2,
					"size": "custom",
					"tileset": "forest"
				}
			file_name = dir.get_next()

func select_custom_map(map_name: String):
	# 移除"Custom_"前缀
	var actual_map_name = map_name.replace("Custom_", "")
	selected_map = "Custom_" + actual_map_name
	map_selected.emit(selected_map)
	print("Custom map selected: ", actual_map_name) 
